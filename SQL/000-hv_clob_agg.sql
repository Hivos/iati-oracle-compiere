
-- Function hv_clobagg combines multiple rows to a single row, internally using CLOB datatype so does not
-- have the limitations of VARCHAR functions LISTAGG or others.

-- http://www.orafaq.com/forum/t/159630/0/

-- http://www.oracle-base.com/articles/misc/string-aggregation-techniques.php
-- On occasion it is necessary to aggregate data from a number of rows into a single row, giving a list of data 
-- associated with a specific value. Using the SCOTT.EMP table as an example, we might want to retrieve a list of 
-- employees for each department. Below is a list of the base data and the type of output we would like to return 
-- from an aggregate query.

-- LISTAGG Analystic Function in 11g Release 2 has a limit of 4000 chars

-- hv_clobagg is used in hv_osco
-- select hv_clobagg(clob|| '  ' ||char|| '  ' ||date) INTO mytext FROM table



create or replace
  type jasper.hv_clobagg_type as object(
                              text clob,
                              static function ODCIAggregateInitialize(
                                                                      sctx in out jasper.hv_clobagg_type
                                                                     )
                                return number,
                              member function ODCIAggregateIterate(
                                                                   self  in out jasper.hv_clobagg_type,
                                                                   value in     clob
                                                                  )
                                return number,
                              member function ODCIAggregateTerminate(
                                                                     self        in  jasper.hv_clobagg_type,
                                                                     returnvalue out clob,
                                                                     flags in number
                                                                    )
                                return number,
                              member function ODCIAggregateMerge(
                                                                 self in out jasper.hv_clobagg_type,
                                                                 ctx2 in     jasper.hv_clobagg_type
                                                                )
                                return number
                             );
/ 
create or replace
  type body jasper.hv_clobagg_type
    is
      static function ODCIAggregateInitialize(
                                              sctx in out jasper.hv_clobagg_type
                                             )
        return number
        is
        begin
            sctx := jasper.hv_clobagg_type(null) ;
            return ODCIConst.Success ;
      end;
      member function ODCIAggregateIterate(
                                           self  in out jasper.hv_clobagg_type,
                                           value in     clob
                                          )
        return number
        is
        begin
            self.text := self.text || ',' || value ;
            return ODCIConst.Success;
      end;
      member function ODCIAggregateTerminate(
                                             self        in  jasper.hv_clobagg_type,
                                             returnvalue out clob,
                                             flags       in  number
                                            )
        return number
        is
        begin
            returnValue := self.text;
            return ODCIConst.Success;
        end;
      member function ODCIAggregateMerge(
                                         self in out jasper.hv_clobagg_type ,
                                         ctx2 in     jasper.hv_clobagg_type
                                        )
        return number
        is
        begin
            self.text := self.text || ctx2.text;
            return ODCIConst.Success;
        end;
end;
/ 
create or replace
  function jasper.hv_clobagg(
                   input clob
                  )
    return clob
    deterministic
    parallel_enable
    aggregate using jasper.hv_clobagg_type;
/ 
