/*************************************************************************
 *
 * TIGHTDB CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2012] TightDB Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of TightDB Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to TightDB Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from TightDB Incorporated.
 *
 **************************************************************************/
#ifndef TIGHTDB_TYPE_LIST_HPP
#define TIGHTDB_TYPE_LIST_HPP

namespace tightdb {


/**
 * The 'cons' operator for building lists of types.
 *
 * \tparam H The head of the list, that is, the first type in the
 * list.
 *
 * \tparam T The tail of the list, that is, the list of types
 * following the head. It is 'void' if nothing follows the head,
 * otherwise it matches TypeCons<H2,T2>.
 *
 * Note that 'void' is considered as a zero-length list.
 */
template<class H, class T> struct TypeCons {
  typedef H head;
  typedef T tail;
};


/**
 * Append a type the the end of a type list. The resulting type list
 * is available as TypeAppend<List, T>::type.
 *
 * \tparam List A list of types constructed using TypeCons<>. Note
 * that 'void' is considered as a zero-length list.
 *
 * \tparam T The new type to be appended.
 */
template<class List, class T> struct TypeAppend {
  typedef TypeCons<typename List::head, typename TypeAppend<typename List::tail, T>::type> type;
};
template<class T> struct TypeAppend<void, T> {
  typedef TypeCons<T, void> type;
};


/**
 * Get an element from the specified list of types. The
 * result is available as TypeAt<List, i>::type.
 *
 * \tparam List A list of types constructed using TypeCons<>. Note
 * that 'void' is considered as a zero-length list.
 *
 * \tparam i The index of the list element to get.
 */
template<class List, int i> struct TypeAt {
  typedef typename TypeAt<typename List::tail, i-1>::type type;
};
template<class List> struct TypeAt<List, 0> { typedef typename List::head type; };


/**
 * Count the number of elements in the specified list of types. The
 * result is available as TypeCount<List>::value.
 *
 * \tparam List The list of types constructed using TypeCons<>. Note
 * that 'void' is considered as a zero-length list.
 */
template<class List> struct TypeCount {
  static const int value = 1 + TypeCount<typename List::tail>::value;
};
template<> struct TypeCount<void> { static const int value = 0; };


/**
 * Execute an action for each element in the specified list of types.
 *
 * \tparam List The list of types constructed using TypeCons<>. Note
 * that 'void' is considered as a zero-length list.
 */
template<class List, int i=0> struct ForEachType {
  template<class Op> static void exec(Op& o)
  {
    o.template exec<typename List::head, i>();
    ForEachType<typename List::tail, i+1>::exec(o);
  }
  template<class Op> static void exec(const Op& o)
  {
    o.template exec<typename List::head, i>();
    ForEachType<typename List::tail, i+1>::exec(o);
  }
};
template<int i> struct ForEachType<void, i> {
  template<class Op> static void exec(Op&) {}
  template<class Op> static void exec(const Op&) {}
};


} // namespace tightdb

#endif // TIGHTDB_TYPE_LIST_HPP
