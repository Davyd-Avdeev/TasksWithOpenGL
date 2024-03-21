unit FourthTask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, OpenGL, ExtCtrls;

type
  TForm4 = class(TForm)
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
  procedure FormCreate(Sender: TObject);
  procedure FormResize(Sender: TObject);
  procedure IdleHandler(Sender: TObject; var Done: Boolean);
  procedure Draw();
  procedure DrawText(tx : array of char);
  procedure DrawObjects();

  procedure BuildFont;
  procedure PrintText(Text : String);

  function bSetupPixelFormat(DC: HDC): Boolean;
  private
    { Private declarations }
    ghRC:HGLRC;
    ghDC:HDC;
  public
    { Public declarations }

  end;

var
  Form4: TForm4;

  fLogFont          : TLogFont;
  fFontName         : TFontName;
  fFontCharset      : TFontCharset;
  txArray: array of char;
const
  CGL_FONT_HEIGHT = -28;
  CGL_START_LIST = 1000;

implementation

{$R *.dfm}

procedure TForm4.FormCreate(Sender: TObject);
var
  p: TGLArrayf4;
  d: TGLArrayf3;
begin
  form4.height:= 800;
  form4.Width:= 1000;
  Form4.Position:=poScreenCenter;

  ghDC := GetDC(Handle);
  if bSetupPixelFormat(ghDC)=false then
     Close();
  ghRC := wglCreateContext(ghDC);
  wglMakeCurrent(ghDC, ghRC);

  glClearColor(0.0, 0.0, 0.0, 0.0);

  FormResize(Sender);

  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_DEPTH_TEST);

  fFontName         := 'Arial';                           // Имя шрифта
  fFontCharset      := DEFAULT_CHARSET;                 // Тип(кодировка) символов

  BuildFont();

  Application.OnIdle := IdleHandler;
end;

procedure TForm4.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Width, Height );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  glOrtho(-5,5, -5,5, 2,12);
  gluLookAt(0,0,5, 0,0,0, 0,1,0);
  glMatrixMode( GL_MODELVIEW );
end;

procedure TForm4.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  Draw();
  Sleep(5);
  Done:=False;
end;

procedure TForm4.Draw();
begin
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
  DrawText(txArray);
  DrawObjects();

  SwapBuffers(ghDC);
end;

procedure TForm4.DrawText(tx : array of char);
var
  i : Integer;
begin
  glLoadIdentity;
  glColor3f(1,1,1);
  glTranslatef(0,0,0);
  for i := 0 to Length(txArray)-1 do
  begin
    PrintText(txArray[i]);
  end;

end;

procedure TForm4.DrawObjects();
var
  i,j:Integer;
begin
  glLoadIdentity;
  glPointSize(12);
  glBegin(GL_POINTS);
    glColor3f(0,1,0);
    glVertex3f(0,0,0);
  glEnd();

end;

procedure TForm4.BuildFont;
var
  hFontNew, hOldFont : HFONT;
  Quality : GLfloat;
begin
//
  Quality :=1000;
  FillChar(fLogFont, SizeOf(fLogFont), 0);
  fLogFont.lfHeight               :=   CGL_FONT_HEIGHT;
  fLogFont.lfWeight               :=   FW_NORMAL;
  fLogFont.lfCharSet              :=   fFontCharset;
  fLogFont.lfOutPrecision         :=   OUT_DEFAULT_PRECIS;
  fLogFont.lfClipPrecision        :=   CLIP_DEFAULT_PRECIS;
  fLogFont.lfQuality              :=   DEFAULT_QUALITY;
  fLogFont.lfPitchAndFamily       :=   FIXED_PITCH;
  fLogFont.lfPitchAndFamily       :=   FF_DONTCARE OR DEFAULT_PITCH;
  fLogFont.lfItalic               :=   0;
  fLogFont.lfWeight               :=   0;
  lstrcpy(fLogFont.lfFaceName, PChar(fFontName));

  hFontNew := CreateFontIndirect(fLogFont);
  hOldFont := SelectObject(ghDC,hFontNew);

  wglUseFontOutlines(ghDC, 0, 255, CGL_START_LIST, Quality, 1, WGL_FONT_POLYGONS, nil);

  DeleteObject(SelectObject(ghDC,hOldFont));
  DeleteObject(SelectObject(ghDC,hFontNew));

  SetLength(txArray, 5);
  txArray[0]:= 'H';
  txArray[1]:= 'e';
  txArray[2]:= 'l';
  txArray[3]:= 'l';
  txArray[4]:= 'o';
end;

procedure TForm4.PrintText(Text: String);
begin
  if Text = '' then Exit;
  glListBase(CGL_START_LIST);
  glCallLists(Length(Text), GL_UNSIGNED_BYTE, PChar(Text));
end;

function TForm4.bSetupPixelFormat(DC: HDC): Boolean;
var
  pxFD: PIXELFORMATDESCRIPTOR;
  ppxfd:PPIXELFORMATDESCRIPTOR;
  pxFormat:integer;
begin
  ppxfd := @pxFD;

  ppxfd.nSize := sizeof(PIXELFORMATDESCRIPTOR);
  ppxfd.nVersion := 1;
  ppxfd.dwFlags :=  PFD_DRAW_TO_WINDOW xor
                     PFD_SUPPORT_OPENGL xor
                     PFD_DOUBLEBUFFER;
  ppxfd.dwLayerMask := PFD_MAIN_PLANE;
  ppxfd.iPixelType := PFD_TYPE_RGBA;
  ppxfd.cColorBits := 16;
  ppxfd.cDepthBits := 16;

  ppxfd.cAccumBits := 0;
  ppxfd.cStencilBits := 0;

  pxFormat := ChoosePixelFormat(dc, ppxfd);

  if pxFormat=0 then
  begin
    MessageBox(0, 'ChoosePixelFormat failed', 'Error', MB_OK);
    bSetupPixelFormat:=FALSE;
    exit;
  end;

  if SetPixelFormat(dc, pxFormat, ppxfd)=false then
  begin
    MessageBox(0, 'SetPixelFormat failed', 'Error', MB_OK);
    bSetupPixelFormat:=FALSE;
    exit;
  end;

  bSetupPixelFormat:=TRUE;
end;

procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ghRC<>0 then
  begin
    wglMakeCurrent(ghDC,0);
    wglDeleteContext(ghRC);
  end;
  if ghDC<>0 then
    ReleaseDC(Handle, ghDC);
end;

end.
