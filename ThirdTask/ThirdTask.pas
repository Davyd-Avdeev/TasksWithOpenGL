unit ThirdTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,  OpenGL;

type
  TForm3 = class(TForm)
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
  procedure FormCreate(Sender: TObject);
  procedure FormResize(Sender: TObject);
  procedure IdleHandler(Sender: TObject; var Done: Boolean);
  procedure Draw();

  function bSetupPixelFormat(DC: HDC): Boolean;
  private
    { Private declarations }
    ghRC:HGLRC;
    ghDC:HDC;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}



procedure TForm3.FormCreate(Sender: TObject);
var
  p: TGLArrayf4;
  d: TGLArrayf3;
begin
  form3.height:= 800;
  form3.Width:= 1000;
  Form3.Position:=poScreenCenter;

  ghDC := GetDC(Handle);
  if bSetupPixelFormat(ghDC)=false then
     Close();
  ghRC := wglCreateContext(ghDC);
  wglMakeCurrent(ghDC, ghRC);

  glClearColor(0.0, 0.0, 0.0, 0.0);

  FormResize(Sender);

  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_DEPTH_TEST);

  Application.OnIdle := IdleHandler;
end;

procedure TForm3.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Width, Height );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  glOrtho(-5,5, -5,5, 2,12);
  gluLookAt(0,0,5, 0,0,0, 0,1,0);
  glMatrixMode( GL_MODELVIEW );
end;

procedure TForm3.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  Draw();
  Sleep(5);
  Done:=False;
end;

procedure TForm3.Draw();
begin
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
  //DrawObjects();
  SwapBuffers(ghDC);
end;

function TForm3.bSetupPixelFormat(DC: HDC): Boolean;
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

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
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
