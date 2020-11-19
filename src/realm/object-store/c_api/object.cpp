#include <realm/object-store/c_api/types.hpp>
#include <realm/object-store/c_api/util.hpp>

#include <realm/util/overload.hpp>

RLM_API bool realm_get_num_objects(const realm_t* realm, realm_table_key_t key, size_t* out_count)
{
    return wrap_err([&]() {
        auto& rlm = **realm;
        auto table = rlm.read_group().get_table(from_capi(key));
        if (out_count)
            *out_count = table->size();
        return true;
    });
}

RLM_API realm_object_t* realm_get_object(const realm_t* realm, realm_table_key_t tbl_key, realm_obj_key_t obj_key)
{
    return wrap_err([&]() {
        auto& shared_realm = *realm;
        auto table_key = from_capi(tbl_key);
        auto table = shared_realm->read_group().get_table(table_key);
        auto obj = table->get_object(from_capi(obj_key));
        auto object = Object{shared_realm, std::move(obj)};
        return new realm_object_t{std::move(object)};
    });
}

RLM_API realm_object_t* realm_object_find_with_primary_key(const realm_t* realm, realm_table_key_t class_key,
                                                           realm_value_t pk, bool* out_found)
{
    return wrap_err([&]() -> realm_object_t* {
        auto& shared_realm = *realm;
        auto table_key = from_capi(class_key);
        auto table = shared_realm->read_group().get_table(table_key);
        auto pk_val = from_capi(pk);

        auto pk_col = table->get_primary_key_column();
        if (pk_val.is_null() && !pk_col.is_nullable()) {
            if (out_found)
                *out_found = false;
            return nullptr;
        }
        if (!pk_val.is_null() && ColumnType(pk_val.get_type()) != pk_col.get_type() &&
            pk_col.get_type() != col_type_Mixed) {
            if (out_found)
                *out_found = false;
            return nullptr;
        }

        auto obj_key = table->find_primary_key(pk_val);
        if (obj_key) {
            if (out_found)
                *out_found = true;
            auto obj = table->get_object(obj_key);
            return new realm_object_t{Object{shared_realm, std::move(obj)}};
        }
        else {
            if (out_found)
                *out_found = false;
            return static_cast<realm_object_t*>(nullptr);
        }
    });
}

RLM_API realm_object_t* realm_object_create(realm_t* realm, realm_table_key_t table_key)
{
    return wrap_err([&]() {
        auto& shared_realm = *realm;
        auto tblkey = from_capi(table_key);
        auto table = shared_realm->read_group().get_table(tblkey);

        if (table->get_primary_key_column()) {
            auto& object_schema = schema_for_table(realm, table_key);
            throw MissingPrimaryKeyException{object_schema.name};
        }

        auto obj = table->create_object();
        auto object = Object{shared_realm, std::move(obj)};
        return new realm_object_t{std::move(object)};
    });
}

RLM_API realm_object_t* realm_object_create_with_primary_key(realm_t* realm, realm_table_key_t table_key,
                                                             realm_value_t pk)
{
    return wrap_err([&]() {
        auto& shared_realm = *realm;
        auto tblkey = from_capi(table_key);
        auto table = shared_realm->read_group().get_table(tblkey);
        // FIXME: Provide did_create?
        auto pkval = from_capi(pk);

        ColKey pkcol = table->get_primary_key_column();
        if (!pkcol) {
            // FIXME: Proper exception type.
            throw std::logic_error("Class does not have a primary key");
        }

        if (pkval.is_null() && !pkcol.is_nullable()) {
            auto& schema = schema_for_table(realm, table_key);
            throw NotNullableException{schema.name, schema.primary_key};
        }

        if (!pkval.is_null() && pkval.get_type() != DataType(pkcol.get_type())) {
            auto& schema = schema_for_table(realm, table_key);
            throw WrongPrimaryKeyTypeException{schema.name};
        }

        auto obj = table->create_object_with_primary_key(pkval);
        auto object = Object{shared_realm, std::move(obj)};
        return new realm_object_t{std::move(object)};
    });
}

RLM_API bool realm_object_delete(realm_object_t* obj)
{
    return wrap_err([&]() {
        auto o = obj->obj();

        if (!obj->is_valid()) {
            auto table = o.get_table();
            auto& schema = schema_for_table(obj->get_realm(), to_capi(table->get_key()));
            throw InvalidatedObjectException{schema.name};
        }

        o.remove();
        return true;
    });
}

RLM_API realm_object_t* _realm_object_from_native_copy(const void* pobj, size_t n)
{
    REALM_ASSERT_RELEASE(n == sizeof(Object));

    return wrap_err([&]() {
        auto pobject = static_cast<const Object*>(pobj);
        return new realm_object_t{*pobject};
    });
}

RLM_API realm_object_t* _realm_object_from_native_move(void* pobj, size_t n)
{
    REALM_ASSERT_RELEASE(n == sizeof(Object));

    return wrap_err([&]() {
        auto pobject = static_cast<Object*>(pobj);
        return new realm_object_t{std::move(*pobject)};
    });
}

RLM_API void* _realm_object_get_native_ptr(realm_object_t* obj)
{
    return static_cast<Object*>(obj);
}

RLM_API bool realm_object_is_valid(const realm_object_t* obj)
{
    return obj->is_valid();
}

RLM_API realm_obj_key_t realm_object_get_key(const realm_object_t* obj)
{
    return to_capi(obj->obj().get_key());
}

RLM_API realm_link_t realm_object_as_link(const realm_object_t* object)
{
    auto obj = object->obj();
    auto table = obj.get_table();
    auto table_key = table->get_key();
    auto obj_key = obj.get_key();
    return realm_link_t{to_capi(table_key), to_capi(obj_key)};
}

RLM_API realm_object_t* realm_object_from_thread_safe_reference(const realm_t* realm,
                                                                realm_thread_safe_reference_t* tsr)
{
    return wrap_err([&]() {
        auto otsr = dynamic_cast<realm_object::thread_safe_reference*>(tsr);
        if (!otsr) {
            throw std::logic_error{"Thread safe reference type mismatch"};
        }

        auto obj = otsr->resolve<Object>(*realm);
        return new realm_object_t{std::move(obj)};
    });
}

RLM_API bool realm_get_value(const realm_object_t* obj, realm_col_key_t col, realm_value_t* out_value)
{
    return realm_get_values(obj, 1, &col, out_value);
}

RLM_API bool realm_get_values(const realm_object_t* obj, size_t num_values, const realm_col_key_t* properties,
                              realm_value_t* out_values)
{
    return wrap_err([&]() {
        auto o = obj->obj();

        // FIXME: For a recently deleted object, this check can be expensive. It
        // would make sense if `Obj::remove()` immediately set `m_valid = false`.
        if (!obj->is_valid()) {
            auto table = o.get_table()->get_key();
            auto& schema = schema_for_table(obj->get_realm(), to_capi(table));
            throw InvalidatedObjectException{schema.name};
        }

        for (size_t i = 0; i < num_values; ++i) {
            auto col_key = from_capi(properties[i]);

            if (col_key.is_collection()) {
                // FIXME: Proper exception type.
                throw std::logic_error("Accessing collection property as value.");
            }

            auto val = o.get_any(col_key);
            out_values[i] = to_capi(val);
        }

        return true;
    });
}

RLM_API bool realm_set_value(realm_object_t* obj, realm_col_key_t col, realm_value_t new_value, bool is_default)
{
    return realm_set_values(obj, 1, &col, &new_value, is_default);
}

RLM_API bool realm_set_values(realm_object_t* obj, size_t num_values, const realm_col_key_t* properties,
                              const realm_value_t* values, bool is_default)
{
    return wrap_err([&]() {
        auto o = obj->obj();

        // FIXME: For a recently deleted object, this check can be expensive. It
        // would make sense if `Obj::remove()` immediately set `m_valid = false`.
        if (!obj->is_valid()) {
            auto table = o.get_table()->get_key();
            auto& schema = schema_for_table(obj->get_realm(), to_capi(table));
            throw InvalidatedObjectException{schema.name};
        }

        // Perform validation up front to avoid partial updates. This is
        // unlikely to incur performance overhead because the object itself is
        // not accessed here, just the bits of the column key and the input type.

        for (size_t i = 0; i < num_values; ++i) {
            auto col_key = from_capi(properties[i]);

            if (col_key.is_collection()) {
                // FIXME: Proper exception type.
                throw std::logic_error("Accessing collection property as value.");
            }

            auto val = from_capi(values[i]);

            if (val.is_null() && !col_key.is_nullable()) {
                auto table = o.get_table();
                auto& schema = schema_for_table(obj->get_realm(), to_capi(table->get_key()));
                throw NotNullableException{schema.name, table->get_column_name(col_key)};
            }

            if (!val.is_null() && col_key.get_type() != ColumnType(val.get_type()) &&
                col_key.get_type() != col_type_Mixed) {
                auto table = o.get_table();
                auto& schema = schema_for_table(obj->get_realm(), to_capi(table->get_key()));
                throw PropertyTypeMismatch{schema.name, table->get_column_name(col_key)};
            }
        }

        // Actually write the properties.

        for (size_t i = 0; i < num_values; ++i) {
            auto col_key = from_capi(properties[i]);
            auto val = from_capi(values[i]);
            o.set_any(col_key, val, is_default);
        }

        return true;
    });
}

RLM_API realm_list_t* realm_get_list(realm_object_t* object, realm_col_key_t key)
{
    return wrap_err([&]() {
        auto obj = object->obj();
        auto table = obj.get_table();

        // FIXME: For a recently deleted object, this check can be expensive. It
        // would make sense if `Obj::remove()` immediately set `m_valid = false`.
        if (!object->is_valid()) {
            auto table_key = table->get_key();
            auto& schema = schema_for_table(object->get_realm(), to_capi(table_key));
            throw InvalidatedObjectException{schema.name};
        }

        auto col_key = from_capi(key);
        table->report_invalid_key(col_key);

        if (!col_key.is_list()) {
            // FIXME: Proper exception type.
            throw std::logic_error{"Not a list property"};
        }

        return new realm_list_t{List{object->get_realm(), std::move(obj), col_key}};
    });
}

RLM_API realm_dictionary_t* realm_get_dictionary(const realm_object_t* object, realm_col_key_t key)
{
    return wrap_err([&]() {
        auto obj = object->obj();
        auto table = obj.get_table();

        // FIXME: For a recently deleted object, this check can be expensive. It
        // would make sense if `Obj::remove()` immediately set `m_valid = false`.
        if (!object->is_valid()) {
            auto table_key = table->get_key();
            auto& schema = schema_for_table(object->get_realm(), to_capi(table_key));
            throw InvalidatedObjectException{schema.name};
        }

        auto col_key = from_capi(key);
        table->report_invalid_key(col_key);

        if (!col_key.is_dictionary()) {
            // FIXME: Proper exception type.
            throw std::logic_error{"Not a dictionary property"};
        }

        return new realm_dictionary_t{object_store::Dictionary{object->get_realm(), std::move(obj), col_key}};
    });
}

RLM_API realm_set_t* realm_get_set(const realm_object_t* object, realm_col_key_t key)
{
    return wrap_err([&]() {
        auto obj = object->obj();
        auto table = obj.get_table();

        // FIXME: For a recently deleted object, this check can be expensive. It
        // would make sense if `Obj::remove()` immediately set `m_valid = false`.
        if (!object->is_valid()) {
            auto table_key = table->get_key();
            auto& schema = schema_for_table(object->get_realm(), to_capi(table_key));
            throw InvalidatedObjectException{schema.name};
        }

        auto col_key = from_capi(key);
        table->report_invalid_key(col_key);

        if (!col_key.is_set()) {
            // FIXME: Proper exception type.
            throw std::logic_error{"Not a set property"};
        }

        return new realm_set_t{object_store::Set{object->get_realm(), std::move(obj), col_key}};
    });
}
