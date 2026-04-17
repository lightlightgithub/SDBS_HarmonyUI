export interface BaseModelInput<T>
{
  operateType:number;   //操作类型  新增：1  修改：2   删除：3
  model:T;
}