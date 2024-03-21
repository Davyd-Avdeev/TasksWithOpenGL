unit FirstTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure Draw;
    procedure DrawObjects();
    procedure DrawSphere();
    procedure DrawAxes();
    procedure IdleHandler(Sender: TObject; var Done: Boolean);

    function bSetupPixelFormat(DC: HDC): Boolean;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    ghRC:HGLRC;
    ghDC:HDC;
    //procedure Draw;
  public
    { Public declarations }
    spin,r,g,b: GLFloat;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//
  if ghRC<>0 then
  begin
    wglMakeCurrent(ghDC,0);
    wglDeleteContext(ghRC);
  end;
  if ghDC<>0 then
    ReleaseDC(Handle, ghDC);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  p: TGLArrayf4;
  d: TGLArrayf3;
begin
  form1.height:= 800;
  form1.Width:= 1000;
  Form1.Position:=poScreenCenter;
  button1.Top := (Height - button1.Height) - 80;
  button1.Left:= (Width - button1.Width) - 60;


  ghDC := GetDC(Handle);
  if bSetupPixelFormat(ghDC)=false then
     Close();
  ghRC := wglCreateContext(ghDC);
  wglMakeCurrent(ghDC, ghRC);

  glClearColor(0.0, 0.0, 0.0, 0.0);

  FormResize(Sender);

  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_DEPTH_TEST);

  spin := 0.0;

  Application.OnIdle := IdleHandler;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Width, Height );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  glOrtho(-5,5, -5,5, 2,12);
  gluLookAt(0,0,5, 0,0,0, 0,1,0);
  glMatrixMode( GL_MODELVIEW );
end;

procedure TForm1.IdleHandler(Sender: TObject; var Done: Boolean);
begin
//
  glRotatef(spin, 0.0, 1.0, 0.0);
  Draw();
  Sleep(5);
  Done:=False;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if (spin = 5) then
    spin:=0
  else
    spin:=5;

end;

procedure TForm1.Draw;
begin
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
  DrawObjects();
  SwapBuffers(ghDC);
end;

procedure TForm1.DrawObjects();
var
  i,j:Integer;
begin
 //
  glBegin(GL_QUADS);
    glColor3f(1,0,0);
    glVertex3f(-1,-1,-1);
    glVertex3f(-1,1,-1);
    glVertex3f(1,1,-1);
    glVertex3f(1,-1,-1);
  glEnd();
  glBegin(GL_QUADS);
    glColor3f(0,0,1);
    glVertex3f(-1,-1,-1);
    glVertex3f(-1,-1,1);
    glVertex3f(-1,1,1);
    glVertex3f(-1,1,-1);
  glEnd();
  glBegin(GL_QUADS);
    glColor3f(1,1,1);
    glVertex3f(1,-1,-1);
    glVertex3f(1,-1,1);
    glVertex3f(1,1,1);
    glVertex3f(1,1,-1);
  glEnd();
  glBegin(GL_QUADS);
    glColor3f(0,1,0);
    glVertex3f(-1,-1,1);
    glVertex3f(-1,1,1);
    glVertex3f(1,1,1);
    glVertex3f(1,-1,1);
  glEnd();

end;

procedure TForm1.DrawSphere();
var
  quadObj: GLUquadricObj;
begin
  quadObj:=gluNewQuadric;
  gluQuadricDrawStyle(quadObj, GLU_FILL);
  glColor3f(1,0,0);
  gluSphere(quadObj, 2,10,10);
  glRotatef(3, 0,1,0);
  gluDeleteQuadric(quadObj);
end;

procedure TForm1.DrawAxes();
var
  i,j:Integer;
begin
  glBegin(GL_LiNES);
    glVertex3f(0, 0, 0);
    glVertex3f(10, 0, 0);
    glVertex3f(0, 0, 0);
    glVertex3f(-10, 0, 0);
    glVertex3f(0, 0, 0);
    glVertex3f(0, 10, 0);
    glVertex3f(0, 0, 0);
    glVertex3f(0, -10, 0);
    glVertex3f(0, 0, 0);
    glVertex3f(0, 0, 10);
    glVertex3f(0, 0, 0);
    glVertex3f(0, 0, -10);
  glEnd();
end;

function TForm1.bSetupPixelFormat(DC: HDC): Boolean;
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
end.
