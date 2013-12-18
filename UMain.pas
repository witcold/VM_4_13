{Задача №13 (интерполирование)
   Программа обеспечивает локальное сглаживание функции, заданной таблицей значений
   в равноотстоящих точках с помощью многочлена третьей степени, построенного
   по пяти точкам методом наименьших квадратов.}
unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, UProcess;

type
  TMForm = class(TForm)
    Im: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Ed_x0: TEdit;
    Ed_xn: TEdit;
    Ed_h: TEdit;
    Ed_e: TEdit;
    Btn_build: TButton;
    Btn_scatter: TButton;
    Btn_smooth: TButton;
    Btn_clear: TButton;
    Label5: TLabel;
    Ed_a: TEdit;
    Ed_b: TEdit;
    Ed_c: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Ed_d: TEdit;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Btn_buildClick(Sender: TObject);
    procedure Btn_clearClick(Sender: TObject);
    procedure Btn_scatterClick(Sender: TObject);
    procedure Btn_smoothClick(Sender: TObject);
  private
    dx : integer; // отступ для image
    x, y, z : TArr;
    nv : integer; // count of elements
    procedure ClearImage (im : TImage);
    procedure makeLine(full : boolean);
  public
    { Public declarations }
  end;
  procedure DrawCircle (CenterX, CenterY, Radius: Integer; Canvas: TCanvas; Color: TColor );

var
  MForm: TMForm;

implementation

{$R *.dfm}

procedure TMForm.FormCreate(Sender: TObject);
begin
  // начальные данные
  Ed_x0.Text:='-2';
  Ed_xn.Text:='5';
  Ed_h.text:='0,3';
  Ed_e.Text:='1,3';

  Ed_a.Text:='1';
  Ed_b.Text:='0';
  Ed_c.Text:='-3';
  Ed_d.Text:='4';
  dx:=20; // отступ для края канвы
end;

// процедура рисования "жирной" точки
procedure DrawCircle( CenterX, CenterY, Radius: Integer; Canvas: TCanvas; Color: TColor );
var clr : TColor;
begin
   clr:=Canvas.Pen.Color;
   Canvas.Pen.Color := Color;
   Canvas.Pen.Style := psSolid;
   Canvas.Pen.Width := 1;
   Canvas.Ellipse(CenterX - Radius, CenterY - Radius, CenterX + Radius, CenterY + Radius);
   Canvas.Pen.Color := Clr;

   clr:=Canvas.Brush.Color;
   Canvas.Brush.Color := Color;
   Canvas.Brush.Style := bsSolid;
   Canvas.FloodFill(CenterX, CenterY, Color, fsBorder);
   Canvas.Brush.Color := Clr;
end;

procedure TMForm.Btn_buildClick(Sender: TObject);
var
  y_min, y_max, x0, xn, h, e, x1, y1 : real;
  i, wid, heig, xNul, yNul : integer;
  a,b,c,d : real;
  xScr, yScr : TArr;
begin
  x0:=StrToFloat(Ed_x0.text);
  xn:=StrToFloat(Ed_xn.text);
  h:=StrToFloat(Ed_h.text);
  x1:=(xn - x0)/h;
  nv := round(x1) + 1;

  if (xn <= x0) then begin
     ShowMessage('Значение конца отрезка должно быть больше, чем у начала');
     Ed_xn.SetFocus;
  end
  else if (h <= 0) then begin
     ShowMessage('Значение шага должно быть больше 0');
     Ed_h.SetFocus;
  end
  else if (StrToFloat(Ed_e.text) <= 0) then begin
     ShowMessage('Значение величины разброса занчений должно быть больше 0');
     Ed_e.SetFocus;
  end
  else if (nv < 5) then
    ShowMessage('Для данного метода количество точек должно быть не меньше 5')
  else begin
    if Ed_a.Text = '' then
      Ed_a.Text := '0';
    if Ed_b.Text = '' then
      Ed_b.Text := '0';
    if Ed_c.Text = '' then
      Ed_c.Text := '0';
    if Ed_d.Text = '' then
      Ed_d.Text := '0';
    a:=StrToFloat(Ed_a.Text);
    b:=StrToFloat(Ed_b.Text);
    c:=StrToFloat(Ed_c.Text);
    d:=StrToFloat(Ed_d.Text);
    wid:=Im.Width;
    heig:=Im.Height;
    // все значения корректны
    ClearImage(im);
    Btn_Scatter.Enabled := true;
    Btn_clear.Enabled :=true;

    x[1]:= x0;
    for i:= 2 to nv do
       x[i]:=x[i-1]+h;

    // заполнить массив y
   for i:= 1 to nv do begin
     x1:=x[i];
     y[i]:=a*sqr(x1)*x1 + b*sqr(x1) + c*x1 +d;
   end;
   MakeLine(true);
  end;
end;

procedure TMForm.MakeLine(full : boolean);
var
  y_min, y_max, x0, xn, h, x1, y1 : real;
  i, wid, heig, xNul, yNul : integer;
  a,b,c,d : real;
  xScr, yScr : TArr;
  clr : TColor;
  // преобразование цвета, заданного как RGB, в TColor
  function RGBToColor(R,G,B:Byte): TColor;
   begin
     Result:=B Shl 16 Or G Shl 8 Or R;
   end;

begin
  x0:=StrToFloat(Ed_x0.text);
  xn:=StrToFloat(Ed_xn.text);
  h:=StrToFloat(Ed_h.text);

    a:=StrToFloat(Ed_a.Text);
    b:=StrToFloat(Ed_b.Text);
    c:=StrToFloat(Ed_c.Text);
    d:=StrToFloat(Ed_d.Text);
    wid:=Im.Width;
    heig:=Im.Height;
    // поиск минимального и максимального элементов в y
       y_min:=y[1];
       y_max:=y[1];
       for i:= 2 to nv do
          if (y[i] > y_max) then y_max:=y[i]
          else if (y[i] < y_min) then y_min:=y[i];

    if full = true then begin
       // все значения корректны
       ClearImage(im);

      Im.Canvas.Pen.Color:=clGray;
       // рисование осей и рисок на них
       //вертикальная линия
       if (x0 >= 0) then begin
          xNul:=dx;
          Im.Canvas.MoveTo(dx, 0);
          Im.Canvas.LineTo(dx, Heig);
       end
       else
         if (xn <= 0) then begin
           xNul:=wid-dx;
           Im.Canvas.MoveTo(wid-2*dx, 0);
           Im.Canvas.LineTo(wid-2*dx, Heig);
         end
         else begin
           xNul:=round(dx- x0/(xn-x0)*(Wid-2*dx));
           Im.Canvas.MoveTo(xNul, 0);
           Im.Canvas.LineTo(xNul, Heig);
         end;

       //горизонтальная линия
       if (y_min >= 0) then begin
          yNul:=heig-dx;
          Im.Canvas.MoveTo(0, Heig-dx);
          Im.Canvas.LineTo(wid, Heig-dx);
       end
       else
         if (y_max <= 0) then begin
           yNul:=dx;
           Im.Canvas.MoveTo(0, dx);
           Im.Canvas.LineTo(wid, dx);
         end
         else begin
           yNul:=round(dx+ y_max/(y_max-y_min)*(Heig-2*dx));
           Im.Canvas.MoveTo(0, yNul);
           Im.Canvas.LineTo(Wid, yNul);
         end;

  // деления по горизонтали
    // если все элементы рассматриваются для неотрицательных x
    if (x0 >= 0) then begin
       x1:= dx + x0/xn*(wid - 2*dx);  // first element
       xScr[1]:=x1;
       Im.Canvas.MoveTo(round(x1), yNul-3);
       Im.Canvas.LineTo(round(x1), yNul+3);
       for i:= 2 to nv do begin
         x1:= x1 +h/xn*(wid - 2*dx); xScr[i]:=x1;
         Im.Canvas.MoveTo(round(x1), yNul-3);
         Im.Canvas.LineTo(round(x1), yNul+3);
       end;
     end
     else
       // если все элементы рассматриваются для неположительных x
       if (xn <= 0) then begin
         x1:=dx;
         xScr[1]:=x1;
         Im.Canvas.MoveTo(round(x1), yNul-3); // first element = x0 = x_min
         Im.Canvas.LineTo(round(x1), yNul+3);
         for i:= 2 to nv do begin
           x1:= x1 -h/x0*(wid - 2*dx); xScr[i]:=x1;
           Im.Canvas.MoveTo(round(x1), yNul-3);
           Im.Canvas.LineTo(round(x1), yNul+3);
         end;
       end
       else
         // если рассматриваются и отрицательные, и положительные x
         begin
           x1:=dx; xScr[1]:=x1;
           Im.Canvas.MoveTo(round(x1), yNul-3); // first element = x0 = x_min
           Im.Canvas.LineTo(round(x1), yNul+3);
           for i:= 2 to nv do begin
             x1:= x1 + h/(xn-x0)*(wid - 2*dx); xScr[i]:=x1;
             Im.Canvas.MoveTo(round(x1), yNul-3);
             Im.Canvas.LineTo(round(x1), yNul+3);
           end;
         end;

  // деления по вертикальной оси
     // если все значения неотрицательны
     if (y_min >= 0) then
       for i:= 1 to nv do begin
         y1:= heig - dx - y[i]/y_max*(heig - 2*dx);    //??????????????????????
         yScr[i]:=y1;
         Im.Canvas.MoveTo(xNul-3, round(y1));
         Im.Canvas.LineTo(xNul+3, round(y1));
       end
     else
       // если все элементы рассматриваются для неположительных x
       if (y_max <= 0) then
         for i:= 1 to nv do begin
           y1:= dx + y[i]/y_min*(heig - 2*dx);
           yScr[i]:=y1;
           Im.Canvas.MoveTo(xNul-3, round(y1));
           Im.Canvas.LineTo(xNul+3, round(y1));
         end
       else
         // если рассматриваются и отрицательные, и положительные x
           for i:= 1 to nv do begin
             y1:= heig - dx - (y[i]-y_min)/(y_max-y_min)*(heig - 2*dx);
             yScr[i]:=y1;
             Im.Canvas.MoveTo(xNul-3, round(y1));
             Im.Canvas.LineTo(xNul+3, round(y1));
           end;
      // подписи значений для крайних элементов
      Im.Canvas.TextOut(round(xScr[1])-5, yNul+2, FloatToStr(x0));
      Im.Canvas.TextOut(round(xScr[nv])-5, yNul+2, FloatToStr(xn));

      Im.Canvas.TextOut(xNul+3, dx-5, FloatToStr(Round(y_max*100)/100));
      Im.Canvas.TextOut(xNul+3, heig-dx-5, FloatToStr(Round(y_min*100)/100));

      // построение самих точек : чтобы они были жирными, рисуем их как круги
      for i:= 1 to nv do
        DrawCircle(round(xScr[i]), round(yScr[i]), 2, Im.Canvas, clBlack);
   end {full}

   else begin
     if (x0 >= 0) then xNul:=dx else
       if (xn <= 0) then xNul:=wid-dx else
           xNul:=round(dx- x0/(xn-x0)*(Wid-2*dx));

    // create xScr
      // если все элементы рассматриваются для неотрицательных x
      if (x0 >= 0) then begin
         x1:= dx + x0/xn*(wid - 2*dx); xScr[1]:=x1;
         for i:= 2 to nv do begin
           x1:= x1 +h/xn*(wid - 2*dx); xScr[i]:=x1;
         end;
       end
       else
         // если все элементы рассматриваются для неположительных x
         if (xn <= 0) then begin
           x1:=dx; xScr[1]:=x1;
           for i:= 2 to nv do begin
             x1:= x1 -h/x0*(wid - 2*dx); xScr[i]:=x1;
           end;
         end
         else
           // если рассматриваются и отрицательные, и положительные x
           begin
             x1:=dx; xScr[1]:=x1;
             for i:= 2 to nv do begin
               x1:= x1 + h/(xn-x0)*(wid - 2*dx); xScr[i]:=x1;
             end;
           end;

    // деления по вертикальной оси
       // если все значения неотрицательны
       if (y_min >= 0) then
         for i:= 1 to nv do begin
           y1:= heig - dx - y[i]/y_max*(heig - 2*dx); yScr[i]:=y1;
           Im.Canvas.MoveTo(xNul-3, round(y1));
           Im.Canvas.LineTo(xNul+3, round(y1));
         end
       else
         // если все элементы рассматриваются для неположительных x
         if (y_max <= 0) then
           for i:= 1 to nv do begin
             y1:= dx + y[i]/y_min*(heig - 2*dx); yScr[i]:=y1;
             Im.Canvas.MoveTo(xNul-3, round(y1));
             Im.Canvas.LineTo(xNul+3, round(y1));
           end
         else
           // если рассматриваются и отрицательные, и положительные x
             for i:= 1 to nv do begin
               y1:= heig - dx - (y[i]-y_min)/(y_max-y_min)*(heig - 2*dx);
               yScr[i]:=y1;
               Im.Canvas.MoveTo(xNul-3, round(y1));
               Im.Canvas.LineTo(xNul+3, round(y1));
             end;
     // при повторном рисовании используем другой цвет точек
     // построение самих точек : чтобы они были жирными, рисуем их как круги
     clr := RGBToColor(random(255),random(255),random(255));
     for i:= 1 to nv do
        DrawCircle(round(xScr[i]), round(yScr[i]), 2, Im.Canvas, clr);

   end;
end;

procedure TMForm.ClearImage (im : TImage);
var
  clrBr, clrPen : TColor;
begin
  clrBr:=Im.Canvas.Brush.Color;
  Im.Canvas.Brush.Color := clWhite;
  clrPen:=Im.Canvas.Pen.Color;
  Im.Canvas.Pen.Color := clWhite;
  Im.Canvas.Rectangle(0, 0, Im.Width, Im.Height);
  Im.Canvas.Brush.Color := clrBr;
  Im.Canvas.Pen.Color := clrPen;
end;

procedure TMForm.Btn_clearClick(Sender: TObject);
begin
  ClearImage(Im);
  Btn_build.Enabled:=true;
  Btn_smooth.Enabled:=false;
  Btn_scatter.Enabled:=false;
end;

 // выполение разброса
procedure TMForm.Btn_scatterClick(Sender: TObject);
var
  i, p : integer;
  e, k: real;
begin
  randomize;
  e:=StrToFloat(Ed_e.text);
  for i:= 2 to nv-1 do begin
    k:=Random;
    p:= random(2);
    if p=1 then
      k:=-k;
    k:=k*e;
    y[i]:=y[i]+ k;
  end;
  MakeLine(true);
  Btn_build.Enabled:=false;
  Btn_smooth.Enabled:=true;
end;

procedure TMForm.Btn_smoothClick(Sender: TObject);
begin
   Smooth(nv, y, z, 5);
   MakeLine(true);
   y:=z;
   MakeLine(false);
end;

end.
