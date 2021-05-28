unit ClipboardUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Clipbrd,
  ExtCtrls, LCLIntf, Buttons, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    cmdEnter: TButton;
    ImageList1: TImageList;
    mnuQuit: TMenuItem;
    mnuLastLink: TMenuItem;
    divOne: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    resetTimer: TTimer;

    TrayIcon1: TTrayIcon;
    procedure cmdEnterClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure mnuQuitClick(Sender: TObject);
    procedure mnuLastLinkClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure resetTimerTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    procedure TrayIcon1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  lastLink: string;

implementation

{$R *.lfm}

{ TForm1 }

function checkTeamsLinkInClipboard(): Boolean;
var
  clipText: string;
  containsTeams: Boolean;
begin
  clipText := Clipboard.AsText;
  if clipText = '' then
  begin
    exit(False);
  end;

  containsTeams := clipText.Contains('https://teams.microsoft.com/l/meetup-');
  exit(containsTeams);
end;

function extract(fromValue: string): string;
var
  extracted: string;
  temp: string;
  start: SizeInt;
  split: TStringArray;
begin
  // Find start of string
  start := fromValue.IndexOf('https://teams.microsoft.com/l/meetup-');

  // Get substring from there
  temp := fromValue.Substring(start);

  split := temp.Split([' ', #10, '<', '>', #13]);
  extracted := split[0];

  exit(extracted);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TrayIcon1.Hint := 'Teams Watcher';
  TrayIcon1.BalloonTitle := 'Teams-Meeting erkannt';
  TrayIcon1.BalloonFlags := bfInfo;
  TrayIcon1.BalloonHint:='In der Zwischenablage befindet sich ein Teams-Link';
  TrayIcon1.Show;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  cmdEnter.Enabled := checkTeamsLinkInClipboard();
end;

procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
  if Form1.WindowState = wsMinimized then
  begin
    Form1.WindowState := wsNormal;
    Form1.Hide();
  end;
end;

procedure TForm1.mnuQuitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.mnuLastLinkClick(Sender: TObject);
begin
  if lastLink <> '' then
  begin
    OpenURL(lastLink);
  end;
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
  mnuLastLink.Enabled := (lastLink <> '');
end;

procedure TForm1.cmdEnterClick(Sender: TObject);
begin
  OpenURL(lastLink);
  Form1.Hide();
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;
  Form1.WindowState:= wsMinimized;
end;

procedure TForm1.resetTimerTimer(Sender: TObject);
begin
  cmdEnter.Enabled := checkTeamsLinkInClipboard();
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  teamsLinkFound: Boolean;
  link: string;
begin
  teamsLinkFound := checkTeamsLinkInClipboard();
  if teamsLinkFound then
  begin
    link := extract(Clipboard.AsText);

    if lastLink <> link then
    begin
      Form1.Show();
      Form1.Position := poDefault;
      TrayIcon1.ShowBalloonHint;
      cmdEnter.Enabled := True;
    end;

    // Remember this one
    lastLink := link;
  end;
end;

procedure TForm1.TrayIcon1Click(Sender: TObject);
begin

end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  if Form1.Visible then
  begin
    Form1.Hide;
  end
  else
  begin
    Form1.Show;
  end;
end;

end.

