unit UProcess;

interface

type
  TType = Real;
  TVector = array [1..100] of TType;
  procedure Smooth(NV: Integer; var Y, Z: TVector; Count: Integer);

implementation

// Cглаживание функции, заданной точками из Y, результат помещается в Z;
// count содержит количество сглаживаний
procedure Smooth(NV: Integer; var Y, Z: TVector; Count: Integer);
var
  i, k : integer;
begin
  Z[1] := Y[1];
  Z[NV] := Y[NV];
  for k := 1 to Count do begin
    Z[2] := (2*Y[1] + 27*Y[2] + 12*Y[3] - 8*Y[4] + 2*Y[5])/35;
    Z[NV-1] := (2*Y[NV-4] - 8*Y[NV-3] + 12*Y[NV-2] + 27*Y[NV-1] + 2*Y[NV])/35;
    for i := 3 to NV-2 do
      Z[i] := (-3*Y[i-2] + 12*Y[i-1] + 17*Y[i] + 12*Y[i+1] - 3*Y[i+2])/35;
  end;    
end;

end.
