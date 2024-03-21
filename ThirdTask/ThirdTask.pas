unit ThirdTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Types;

type
  TForm3 = class(TForm)
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
  procedure FormCreate(Sender: TObject);
  procedure FormResize(Sender: TObject);
  procedure IdleHandler(Sender: TObject; var Done: Boolean);
  procedure Draw();
  procedure DrawWorld();
  procedure DrawObject();
  procedure MoveCamera();
  procedure ButtonHandler();

  function bSetupPixelFormat(DC: HDC): Boolean;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    ghRC:HGLRC;
    ghDC:HDC;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  vert: array[0..11] of GLFloat;
  vertTriangle: array[0..17] of GLFloat;
  vertTriangleIndex: array[0..11] of GLuint;
  keysPressed: array[0..7] of Boolean;
  xAlfa, zAlfa,speed, angle: GLFloat;
    CameraPos: TPointF;


implementation

{$R *.dfm}



procedure TForm3.FormCreate(Sender: TObject);
var
  p: TGLArrayf4;
  d: TGLArrayf3;
  i: Integer;
begin
  form3.height:= 800;
  form3.Width:= 800;
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

  angle:= 0;
  CameraPos.X:=0; CameraPos.Y:=0;
  vert[0]:= 1; vert[1]:= 1; vert[2]:= 0;
  vert[3]:= 1; vert[4]:= -1; vert[5]:= 0;
  vert[6]:= -1; vert[7]:= -1; vert[8]:= 0;
  vert[9]:= -1; vert[10]:= 1; vert[11]:= 0;

  vertTriangle[0]:= 0; vertTriangle[1]:= 0; vertTriangle[2]:= 2;
  vertTriangle[3]:= 1; vertTriangle[4]:= 1; vertTriangle[5]:= 0;
  vertTriangle[6]:= 1; vertTriangle[7]:= -1; vertTriangle[8]:= 0;
  vertTriangle[9]:= -1; vertTriangle[10]:= -1; vertTriangle[11]:= 0;
  vertTriangle[12]:= -1; vertTriangle[13]:= 1; vertTriangle[14]:= 0;
  vertTriangle[15]:= 1; vertTriangle[16]:= 1; vertTriangle[17]:= 0;

  vertTriangleIndex[0]:= 0; vertTriangleIndex[1]:= 1; vertTriangleIndex[2]:= 2;
  vertTriangleIndex[3]:= 0; vertTriangleIndex[4]:= 1; vertTriangleIndex[5]:= 3;
  vertTriangleIndex[6]:= 0; vertTriangleIndex[7]:= 2; vertTriangleIndex[8]:= 3;
  vertTriangleIndex[9]:= 1; vertTriangleIndex[10]:= 2; vertTriangleIndex[11]:= 3;
  for i := 0 to Length(keysPressed)-1 do
    keysPressed[i]:= False;

  Application.OnIdle := IdleHandler;
end;



procedure TForm3.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Width, Height );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  glFrustum(-1,1, -1,1, 2,80);
  glMatrixMode( GL_MODELVIEW );
end;

procedure TForm3.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  ButtonHandler();
  Draw();
  Sleep(5);
  Done:=False;
end;

procedure TForm3.Draw();
begin
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
  glPushMatrix();
    MoveCamera();
    DrawWorld();
    //DrawObject();
  glPopMatrix();
  SwapBuffers(ghDC);
end;

procedure TForm3.DrawObject();
begin
  //glLoadIdentity();
  glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, @vertTriangle);
    glColor3f(1,0,0);
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, @vertTriangleIndex);
  glDisableClientState(GL_VERTEX_ARRAY);
end;

procedure TForm3.DrawWorld();
var
  i,j: Integer;
begin
  glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, @vert);
    for i := -5 to 5 do
      for j := -5 to 5 do
      begin
        if(((i+j) mod 2) = 0) then glColor3f(0,0.5,0)
        else glColor3f(1,1,1);
        glPushMatrix();
          glTranslateF(i*2, j*2, 0);
          glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        glPopMatrix();
      end;

    glVertexPointer(3, GL_FLOAT, 0, @vertTriangle);
    glColor3f(1,0,0);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 6);

  glDisableClientState(GL_VERTEX_ARRAY);
end;

procedure TForm3.MoveCamera();
begin
  glRotateF(-xAlfa, 1,0,0);
  glRotateF(-zAlfa, 0,0,1);

  glTranslateF(-CameraPos.X,-CameraPos.Y,-3);
end;

procedure TForm3.ButtonHandler;
begin
  if(keysPressed[0])then
  begin
    xAlfa:= xAlfa+1;
    if(xAlfa >= 180) then
      xAlfa := 180;
  end;
  if(keysPressed[1])then
  begin
    xAlfa:= xAlfa-1;
    if(xAlfa <= 0) then
      xAlfa:= 0;
  end;
  if(keysPressed[2])then
  begin
    zAlfa:= zAlfa-1;
  end;
  if(keysPressed[3])then
  begin
    zAlfa:= zAlfa+1;
  end;

  angle:= (zalfa+90)/180 * PI;
  speed:= 0;

  if(keysPressed[4])then
  begin
    speed:= 0.1;
  end;
  if(keysPressed[5])then
  begin
    speed:= -0.1;
  end;
  if(keysPressed[6])then
  begin
    speed:= 0.1;
    angle:= angle + PI * 0.5;
  end;
  if(keysPressed[7])then
  begin
    speed:= 0.1;
    angle:= angle - PI * 0.5;
  end;

  if(speed <> 0)then
  begin
    cameraPos.X:=CameraPos.X + (cos(angle) * speed);
    cameraPos.Y:=CameraPos.Y + (sin(angle) * speed);
  end;

end;

procedure TForm3.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then
      keysPressed[0]:= True;
  if Key = VK_DOWN then
      keysPressed[1]:= True;
  if Key = VK_RIGHT then
      keysPressed[2]:= True;
  if Key = VK_LEFT then
      keysPressed[3]:= True;

  if Key = 87 then
      keysPressed[4]:= True;
  if Key = 83 then
      keysPressed[5]:= True;
  if Key = 65 then
      keysPressed[6]:= True;
  if Key = 68 then
      keysPressed[7]:= True;
end;

procedure TForm3.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then
    keysPressed[0]:= False;
  if Key = VK_DOWN then
    keysPressed[1]:= False;
  if Key = VK_RIGHT then
    keysPressed[2]:= False;
  if Key = VK_LEFT then
    keysPressed[3]:= False;

  if Key = 87 then
    keysPressed[4]:= False;
  if Key = 83 then
    keysPressed[5]:= False;
  if Key = 65 then
    keysPressed[6]:= False;
  if Key = 68 then
    keysPressed[7]:= False;
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
