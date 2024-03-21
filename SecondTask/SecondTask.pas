unit SecondTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL;

type
  TObj = class
    X, Y, XSpeed, YSpeed, XVector, YVector :GLFloat;
    constructor Create(_x, _y: GLFloat);
  end;
  TForm2 = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BuildFont();
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure IdleHandler(Sender: TObject; var Done: Boolean);
    procedure Draw();
    procedure DrawObjects();
    procedure DrawText();
    procedure PrintText(Text: String);
    procedure MovingObjects();
    procedure ObjectsBehavior();
    procedure WasGoal();

    function bSetupPixelFormat(DC: HDC): Boolean;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    ghRC:HGLRC;
    ghDC:HDC;
  public
    { Public declarations }
    keysPressed: array of Boolean;
  end;

var
  Form2: TForm2;
  objectsArray: array of TObj;
  fLogFont: TLogFont;
  scorePlayer1: Cardinal;
  scorePlayer2: Cardinal;
  isWasGool: Boolean;
  timeFloatStart, timeFloatCurrent: Real;
const
  CGL_FONT_HEIGHT = -28;
  CGL_START_LIST = 1000;

implementation

{$R *.dfm}

constructor TObj.Create(_x, _y: GLFloat);
begin
  X:= _x;
  Y:= _Y;
  XSpeed:= 8;
  YSpeed:= 10;
  XVector:= 1;
  YVector:= 1;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  p: TGLArrayf4;
  d: TGLArrayf3;
begin
  form2.height:= 800;
  form2.Width:= 800;
  Form2.Position:=poScreenCenter;

  ghDC := GetDC(Handle);
  if bSetupPixelFormat(ghDC)=false then
     Close();
  ghRC := wglCreateContext(ghDC);
  wglMakeCurrent(ghDC, ghRC);

  glClearColor(0.0, 0.0, 0.0, 0.0);

  FormResize(Sender);

  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_DEPTH_TEST);

  SetLength(objectsArray, 3);
  objectsArray[0]:= TObj.Create(-4.7, 0);
  objectsArray[1]:= TObj.Create(4.5, 0);
  objectsArray[2]:= TObj.Create(0, 0);
  objectsArray[2].XSpeed:= 11;
  objectsArray[2].YSpeed:= 0;
  SetLength(keysPressed, 4);
  keysPressed[0]:= False;
  keysPressed[1]:= False;
  keysPressed[2]:= False;
  keysPressed[3]:= False;
  scorePlayer1:= 0;
  scorePlayer1:= 0;

  BuildFont();
  Application.OnIdle := IdleHandler;
end;

procedure TForm2.FormResize(Sender: TObject);
begin
  glViewport(0, 0, Width, Height );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  glOrtho(-5,5, -5,5, 2,12);
  gluLookAt(0,0,5, 0,0,0, 0,1,0);
  glMatrixMode( GL_MODELVIEW );
end;

procedure TForm2.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  MovingObjects();
  ObjectsBehavior();
  Draw();
  Sleep(5);
  Done:=False;
end;

procedure TForm2.MovingObjects();
begin
  if keysPressed[0] or keysPressed[1] then
    if keysPressed[0] then
    begin
      if (objectsArray[1].Y <= 3.53) then
        objectsArray[1].YVector:= 1
      else
        objectsArray[1].YVector:= 0;
    end
    else
    begin
      if (objectsArray[1].Y >= -4) then
        objectsArray[1].YVector:= -1
      else
        objectsArray[1].YVector:= 0;
    end
  else
    objectsArray[1].YVector:= 0;

  if keysPressed[2] or keysPressed[3] then
    if keysPressed[2] then
    begin
      if (objectsArray[0].Y <= 3.53) then
        objectsArray[0].YVector:= 1
      else
        objectsArray[0].YVector:= 0;
    end
    else
    begin
      if (objectsArray[0].Y >= -4) then
        objectsArray[0].YVector:= -1
      else
        objectsArray[0].YVector:= 0;
    end
  else
    objectsArray[0].YVector:= 0;

  objectsArray[0].Y:= objectsArray[0].Y + 0.01 * objectsArray[0].YSpeed * objectsArray[0].YVector;
  objectsArray[1].Y:= objectsArray[1].Y + 0.01 * objectsArray[1].YSpeed * objectsArray[1].YVector;

  if(isWasGool) then
    if (timeFloatCurrent <= 500) then
    begin
      timeFloatCurrent:= timeFloatCurrent + 5;
      Exit();
    end
    else
    begin
     timeFloatCurrent:= 0;
     isWasGool:= False;
    end;
  objectsArray[2].X:= objectsArray[2].X - 0.01 * objectsArray[2].XSpeed;
  objectsArray[2].Y:= objectsArray[2].Y - 0.01 * objectsArray[2].YSpeed * objectsArray[2].YVector;
end;

procedure TForm2.ObjectsBehavior();
begin
  if(objectsArray[2].X >= objectsArray[0].X-0.2) And (objectsArray[2].X <= objectsArray[0].X) then
    if (objectsArray[2].Y <= objectsArray[0].Y + 0.75) And (objectsArray[2].Y >= objectsArray[0].Y - 0.75) then
    begin
      objectsArray[2].XSpeed:= objectsArray[2].XSpeed * -1;
      if(objectsArray[0].YVector = 0) then
      else
      begin
        objectsArray[2].YSpeed:= objectsArray[0].YSpeed/2 + objectsArray[2].YSpeed * 0.05;
        objectsArray[2].XSpeed:= objectsArray[2].XSpeed + objectsArray[2].XSpeed*0.05;
        objectsArray[2].YVector:= -objectsArray[0].YVector;
      end;
    end;
  if(objectsArray[2].X >= objectsArray[1].X) And (objectsArray[2].X <= objectsArray[1].X+0.2) then
    if (objectsArray[2].Y <= objectsArray[1].Y + 0.75) And (objectsArray[2].Y >= objectsArray[1].Y - 0.75) then
      begin
        objectsArray[2].XSpeed:= objectsArray[2].XSpeed * -1;
        if(objectsArray[1].YVector = 0) then
        else
        begin
          objectsArray[2].YSpeed:= objectsArray[1].YSpeed/2 + objectsArray[2].YSpeed * 0.05;
          objectsArray[2].XSpeed:= objectsArray[2].XSpeed + objectsArray[2].XSpeed*0.2;
          objectsArray[2].YVector:= -objectsArray[1].YVector;
        end;
      end;

  if(objectsArray[2].Y >= 4.35) And (objectsArray[2].Y <= 4.55) then
    objectsArray[2].YSpeed := objectsArray[2].YSpeed * -1;
  if(objectsArray[2].Y >= -5) And (objectsArray[2].Y <= -4.8) then
    objectsArray[2].YSpeed := objectsArray[2].YSpeed * -1;

  if(objectsArray[2].X >= 4.8)then
  begin
    WasGoal();
    Inc(scorePlayer1);
  end;
  if(objectsArray[2].X <= -5)then
  begin
    WasGoal();
    Inc(scorePlayer2);
  end;

end;

procedure TForm2.WasGoal();
begin
  objectsArray[2].XSpeed := 11;
  objectsArray[2].YSpeed := 0;
  objectsArray[2].X:= 0;
  objectsArray[2].Y:= 0;
  isWasGool:= True;
  timeFloatCurrent:= 0;
end;

procedure TForm2.Draw();
begin
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
  DrawText();
  DrawObjects();
  SwapBuffers(ghDC);
end;

procedure TForm2.DrawObjects;
begin
  glLoadIdentity;
  glBegin(GL_QUADS);
    glVertex3f(-5, 4.55, 0);
    glVertex3f(4.8, 4.55, 0);
    glVertex3f(4.8, 4.35, 0);
    glVertex3f(-5, 4.35, 0);
  glEnd();
  glBegin(GL_QUADS);
    glVertex3f(-5, -5, 0);
    glVertex3f(4.8, -5, 0);
    glVertex3f(4.8, -4.8, 0);
    glVertex3f(-5, -4.8, 0);
  glEnd();
  glBegin(GL_QUADS);
    glVertex3f(objectsArray[1].X+0.2, objectsArray[1].Y+0.75, 0);
    glVertex3f(objectsArray[1].X, objectsArray[1].Y+0.75, 0);
    glVertex3f(objectsArray[1].X, objectsArray[1].Y-0.75, 0);
    glVertex3f(objectsArray[1].X+0.2, objectsArray[1].Y-0.75, 0);
  glEnd();
  glBegin(GL_QUADS);
    glVertex3f(objectsArray[0].X, objectsArray[0].Y+0.75, 0);
    glVertex3f(objectsArray[0].X-0.2, objectsArray[0].Y+0.75, 0);
    glVertex3f(objectsArray[0].X-0.2, objectsArray[0].Y-0.75, 0);
    glVertex3f(objectsArray[0].X, objectsArray[0].Y-0.75, 0);
  glEnd();
  glEnable( GL_POINT_SMOOTH );
  glPointSize(12);
  glBegin(GL_POINTS);
    glVertex3f(objectsArray[2].X, objectsArray[2].Y, 0);
  glEnd();
  glDisable( GL_POINT_SMOOTH );
end;

procedure TForm2.DrawText();
var
  i : Integer;
  scoreText: string;
begin
  glLoadIdentity;
  glColor3f(1,1,1);
  glTranslatef(-1,3.5,0);
  glScalef(1/2,1/2,1);
  scoreText:= IntToStr(scorePlayer1);
  for i := 1 to Length(scoreText) do
  begin
    PrintText(scoreText[i]);
  end;

  glLoadIdentity;
  glTranslatef(1,3.5,0);
  glScalef(1/2,1/2,1);
  scoreText:= IntToStr(scorePlayer2);
  for i := 1 to Length(scoreText) do
  begin
    PrintText(scoreText[i]);
  end;

end;

procedure TForm2.PrintText(Text: String);
begin
  if Text = '' then Exit;
  glListBase(CGL_START_LIST);
  glCallLists(Length(Text), GL_UNSIGNED_BYTE, PChar(Text));
end;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // проверка нажатой клавиши
  if Key = VK_UP then
    if (objectsArray[1].Y <= 3.5) then
      keysPressed[0]:= True;
  if Key = VK_DOWN then
    if (objectsArray[1].Y >= -3.85) then
      keysPressed[1]:= True;
  if Key = 87 then
    if (objectsArray[0].Y <= 3.5) then
      keysPressed[2]:= True;

  if Key = 83 then
    if (objectsArray[0].Y >= -3.85) then
      keysPressed[3]:= True;
end;

procedure TForm2.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then
    keysPressed[0]:= False;

  if Key = VK_DOWN then
    keysPressed[1]:= False;

  if Key = 87 then
    keysPressed[2]:= False;

  if Key = 83 then
    keysPressed[3]:= False;
end;

procedure TForm2.BuildFont();
var
  hFontNew, hOldFont : HFONT;
  Quality : GLfloat;
begin
  Quality :=1000;
  FillChar(fLogFont, SizeOf(fLogFont), 0);
  fLogFont.lfHeight               :=   CGL_FONT_HEIGHT;
  fLogFont.lfWeight               :=   FW_NORMAL;
  fLogFont.lfCharSet              :=   DEFAULT_CHARSET;
  fLogFont.lfOutPrecision         :=   OUT_DEFAULT_PRECIS;
  fLogFont.lfClipPrecision        :=   CLIP_DEFAULT_PRECIS;
  fLogFont.lfQuality              :=   DEFAULT_QUALITY;
  fLogFont.lfPitchAndFamily       :=   FIXED_PITCH;
  fLogFont.lfPitchAndFamily       :=   FF_DONTCARE OR DEFAULT_PITCH;
  fLogFont.lfItalic               :=   0;
  fLogFont.lfWeight               :=   0;
  lstrcpy(fLogFont.lfFaceName, PChar('Arial'));

  hFontNew := CreateFontIndirect(fLogFont);
  hOldFont := SelectObject(ghDC,hFontNew);

  wglUseFontOutlines(ghDC, 0, 255, CGL_START_LIST, Quality, 1, WGL_FONT_POLYGONS, nil);

  DeleteObject(SelectObject(ghDC,hOldFont));
  DeleteObject(SelectObject(ghDC,hFontNew));
end;

function TForm2.bSetupPixelFormat(DC: HDC): Boolean;
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

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
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
