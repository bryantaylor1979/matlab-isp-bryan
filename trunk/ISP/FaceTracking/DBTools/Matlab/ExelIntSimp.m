function [StructOut, RetValue]=ExelIntSimp(Op,ImageFileName,PageIn, FieldIn, ValueIn, Page2Match, Field2Match, Value2Match)
%Simplier interface to Exel 
%use only one page and field to insert\Update\Get and only one Page,Field
%Value as filter
%returnes in addition to the full structure, a single value of the In Field
StructIn.(PageIn).(FieldIn)=ValueIn;
StructMatch.(Page2Match).(Field2Match)=Value2Match;

StructOut=ExelInt(Op,ImageFileName,StructIn,StructMatch,[]);
if isfield(StructOut,PageIn) && isfield(StructOut.(PageIn),FieldIn)
    RetValue=StructOut.(PageIn).(FieldIn)(1);
else
    RetValue=[];
end