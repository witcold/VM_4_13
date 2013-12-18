{
Çàäà÷à ¹13 (èíòåðïîëèðîâàíèå)
Ïðîãðàììà îáåñïå÷èâàåò ëîêàëüíîå ñãëàæèâàíèå ôóíêöèè, çàäàííîé òàáëèöåé çíà÷åíèé
â ðàâíîîòñòîÿùèõ òî÷êàõ ñ ïîìîùüþ ìíîãî÷ëåíà òðåòüåé ñòåïåíè, ïîñòðîåííîãî
ïî ïÿòè òî÷êàì ìåòîäîì íàèìåíüøèõ êâàäðàòîâ.
}
unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, 
  UProcess;

type
  TMForm = class(TForm)
    Image: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Ed_x0: TEdit;
    Ed_xn: TEdit;
    Ed_a: TEdit;
    Ed_b: TEdit;
    Ed_c: TEdit;
    Ed_d: TEdit;
    Ed_e: TEdit;
    Ed_h: TEdit;
    Btn_build: TButton;
    Btn_scatter: TButton;
    Btn_smooth: TButton;
    Btn_clear: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Btn_buildClick(Sender: TObject);
    procedure Btn_clearClick(Sender: TObject);
    procedure Btn_scatterClick(Sender: TObject);
    procedure Btn_smoothClick(Sender: TObject);
  private
    X, Y, Z: TVector;
    NV: Integer;
    procedure ClearImage(I: TImage);
    procedure MakeCoords;
    procedure MakeLine(Color: TColor);
  public
  end;

var
  MForm: TMForm;
  x0, xN: TType;
  a, b, c, d, e, h: TType;
  cx0, cy0, cx1, cy1: Integer;

implementation

uses Math;

{$R *.dfm}

procedure TMForm.FormCreate(Sender: TObject);
begin
  Ed_x0.Text := '-2';
  Ed_xn.Text := '5';
  Ed_h.text := '0,3';
  Ed_e.Text := '1,3';

  Ed_a.Text := '0,2';
  Ed_b.Text := '0';
  Ed_c.Text := '-3';
  Ed_d.Text := '4';
end;

procedure TMForm.ClearImage(I: TImage);
begin
  I.Canvas.Brush.Color := clWhite;
  I.Canvas.Pen.Color := clBlack;
  I.Canvas.Rectangle(0, 0, I.Width, I.Height);
end;

procedure Dot(X, Y: TType; Canvas: TCanvas; Color: TColor);
var
  cx, cy, R: Integer;
begin
  R := 2;
  Canvas.Pen.Color := Color;
  Canvas.Brush.Color := Color;
  cx := cx0 + Round(X * cx1);
  cy := cy0 - Round(Y * cy1);
  Canvas.Ellipse(cx - R, cy - R, cx + R, cy + R);
end;

procedure Line(FromX, FromY, ToX, ToY: TType; Canvas: TCanvas; Color: TColor);
var
  cx, cy: Integer;
begin
  Canvas.Pen.Color := Color;
  cx := cx0 + Round(FromX * cx1);
  cy := cy0 - Round(FromY * cy1);
  Canvas.MoveTo(cx, cy);
  cx := cx0 + Round(ToX * cx1);
  cy := cy0 - Round(ToY * cy1);
  Canvas.LineTo(cx, cy);
end;

procedure DrawCoordinates(MinX, MinY, MaxX, MaxY: TType; W, H: Integer; Canvas: TCanvas);
var
  i, t: Integer;
  S: String;
begin
  cx1 := Round(W / (MaxX - MinX));
  cy1 := Round(H / (MaxY - MinY));
  cx0 := (W - Round(Abs(MaxX + MinX)) * cx1) div 2;
  cy0 := (H + Round(Abs(MaxY + MinY)) * cy1) div 2;
  // Draw coordinate axis
  with Canvas do begin
    Pen.Color := clGray;
    MoveTo(0, cy0);
    LineTo(W, cy0);
    MoveTo(cx0, 0);
    LineTo(cx0, H);
    // Draw numbers
    for i := 1 to Floor(Abs(MaxX)) do begin
      MoveTo(cx0 + i * cx1, cy0 - 2);
      LineTo(cx0 + i * cx1, cy0 + 3);
      S := IntToStr(i);
      t := Canvas.TextWidth(S) div 2;
      TextOut(cx0 + i * cx1 - t, cy0 + 5, S);
    end;
    for i := 1 to Floor(Abs(MinX)) do begin
      MoveTo(cx0 - i * cx1, cy0 - 2);
      LineTo(cx0 - i * cx1, cy0 + 3);
      S := IntToStr(-i);
      t := Canvas.TextWidth(S) div 2;
      TextOut(cx0 - i * cx1 - t, cy0 + 5, S);
    end;
    for i := 1 to Floor(Abs(MaxY)) do begin
      MoveTo(cx0 - 2, cy0 - i * cy1);
      LineTo(cx0 + 3, cy0 - i * cy1);
      S := IntToStr(i);
      t := Canvas.TextHeight(S) div 2;
      TextOut(cx0 + 5, cy0 - i * cy1 - t, S);
    end;
    for i := 1 to Floor(Abs(MinY)) do begin
      MoveTo(cx0 - 2, cy0 + i * cy1);
      LineTo(cx0 + 3, cy0 + i * cy1);
      S := IntToStr(-i);
      t := Canvas.TextHeight(S) div 2;
      TextOut(cx0 + 5, cy0 + i * cy1 - t, S);
    end;
  end;
end;

procedure TMForm.Btn_buildClick(Sender: TObject);
var
  i: Integer;
begin
  x0 := StrToFloatDef(Ed_x0.text, 0);
  xN := StrToFloatDef(Ed_xn.text, 0);
  h := StrToFloatDef(Ed_h.text, 0);
  a := StrToFloatDef(Ed_a.Text, 0);
  b := StrToFloatDef(Ed_b.Text, 0);
  c := StrToFloatDef(Ed_c.Text, 0);
  d := StrToFloatDef(Ed_d.Text, 0);
  e := StrToFloatDef(Ed_e.text, 0);
  NV := round((xN - x0) / h) + 1;

  if (xN < x0) then
    ShowMessage('Íåâåðíî çàäàíû êîíöû îòðåçêà!');
  if (h <= 0) then
    ShowMessage('Çíà÷åíèå øàãà äîëæíî áûòü áîëüøå 0');
  if (StrToFloat(Ed_e.text) <= 0) then
    ShowMessage('Çíà÷åíèå âåëè÷èíû ðàçáðîñà çàí÷åíèé äîëæíî áûòü áîëüøå 0');
  if (NV < 5) then
    ShowMessage('Äëÿ äàííîãî ìåòîäà êîëè÷åñòâî òî÷åê äîëæíî áûòü íå ìåíüøå 5');

  // âñå çíà÷åíèÿ êîððåêòíû
  ClearImage(Image);
  Btn_Scatter.Enabled := true;
  Btn_clear.Enabled := true;

  x[1] := x0;
  y[1] := a*sqr(x0)*x0 + b*sqr(x0) + c*x0 + d;
  for i := 2 to NV do begin
    x[i] := x[i-1] + h;
    y[i] := a*sqr(x[i])*x[i] + b*sqr(x[i]) + c*x[i] + d;
  end;

  MakeCoords;
  MakeLine(clBlack);
end;

procedure TMForm.MakeCoords;
var
  y_min, y_max: TType;
  i: Integer;
begin
  // ïîèñê ìèíèìàëüíîãî è ìàêñèìàëüíîãî ýëåìåíòîâ â Y
  y_min := y[1];
  y_max := y[1];
  for i := 2 to NV do
    if (y[i] > y_max) then
      y_max := y[i]
    else
      if (y[i] < y_min) then
        y_min := y[i];
  DrawCoordinates(x0,y_min,xN,y_max,Image.Width,Image.Height,Image.Canvas);
end;

procedure TMForm.MakeLine(Color: TColor);
var
  i: Integer;
begin
  Dot(x[1],y[1],Image.Canvas,clBlack);
  for i := 2 to NV do begin
    Line(x[i-1],y[i-1],x[i],y[i],Image.Canvas,Color);
    Dot(x[i],y[i],Image.Canvas,Color);
  end;
end;

procedure TMForm.Btn_clearClick(Sender: TObject);
begin
  ClearImage(Image);
  Btn_build.Enabled:=true;
  Btn_smooth.Enabled:=false;
  Btn_scatter.Enabled:=false;
end;

// âûïîëåíèå ðàçáðîñà
procedure TMForm.Btn_scatterClick(Sender: TObject);
var
  i: Integer;
  k: real;
begin
  Randomize;
  for i:= 2 to NV-1 do begin
    k := Random;
    if Random > 0.5 then
      k := -k;
    y[i] := y[i] + k * e;
  end;
  MakeLine(clRed);
  Btn_build.Enabled:=false;
  Btn_smooth.Enabled:=true;
end;

procedure TMForm.Btn_smoothClick(Sender: TObject);
begin
  Smooth(nv, y, z, 5);
  y:=z;
  MakeLine(clGreen);
end;

end.
