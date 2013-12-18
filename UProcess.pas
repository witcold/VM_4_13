unit UProcess;

interface
type
  TArr = array [1..400] of real;
  procedure Smooth(nv : integer; y : TArr; var z  : TArr; count : integer);

implementation

// выполнение сглаживание функции, заданной точками y. результат помещается в z;
// count содержит количество повторений сглаживаний
procedure Smooth(nv : integer; y : TArr; var z  : TArr; count : integer);
var i, r : integer;
begin
  z[1]:=y[1];
  z[nv]:=y[nv];
  for r:= 1 to count do begin
    z[2]:=   (2*y[1] + 27*y[2] + 12*y[3] - 8*y[4] + 2*y[5])/35;
    z[nv-1]:=(2*y[nv-4] - 8*y[nv-3] + 12*y[nv-2] + 27*y[nv-1] + 2*y[nv])/35;
    for i:= 3 to nv-2 do
      z[i]:= ((-3)*y[i-2] + 12*y[i-1] + 17*y[i] + 12*y[i+1] - 3*y[i+2])/35;
  end;    
end;

end.
 
