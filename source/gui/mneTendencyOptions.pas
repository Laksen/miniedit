unit mneTendencyOptions;
{$mode objfpc}{$H+}
{**
 * Mini Edit
 *
 * @license    GPL 2 (http://www.gnu.org/licenses/gpl.html)
 * @author    Zaher Dirkey <zaher at parmaja dot com>
 *}

interface

uses
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, SynEdit,
  EditorEngine, DebugClasses, mneClasses, Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus;

type

  { TTendencyForm }

  TTendencyForm = class(TForm)
    Label11: TLabel;
    TabsSpecialEdit: TEdit;
    GroupBox1: TGroupBox;
    Label10: TLabel;
    Label9: TLabel;
    OkBtn: TButton;
    CancelBtn: TButton;
    OverrideOptionsChk: TCheckBox;
    PageControl: TPageControl;
    GeneralSheet: TTabSheet;
    TabsToSpacesChk: TCheckBox;
    TabWidthEdit: TEdit;
    procedure PageControlChanging(Sender: TObject; var AllowChange: Boolean);
  private
    FTendency: TEditorTendency;
    FFrames: array of TFrame;
  protected
    procedure AddFrame(AFrame: TFrame);
  public
    procedure ApplyFrames;
    procedure Apply;
    procedure RetrieveFrames;
    procedure Retrieve;
  end;

function ShowTendencyForm(vTendency: TEditorTendency): Boolean;

implementation

uses mneResources;

{$R *.lfm}

function ShowTendencyForm(vTendency: TEditorTendency): Boolean;
begin
  with TTendencyForm.Create(Application) do
  begin
    FTendency := vTendency;
    RetrieveFrames;
    Retrieve;
    PageControl.ActivePage := GeneralSheet;
    //ActiveControl := NameEdit;
    Result := ShowModal = mrOk;
    if Result then
    begin
      Apply;
      ApplyFrames;
      Engine.Options.Apply;
      Engine.UpdateState([ecsOptions]);
    end;
    Free;
  end;
end;

procedure TTendencyForm.Apply;
  procedure SetFlag(aOption: TSynEditorOption; aValue: boolean);
  begin
    if aValue then
      FTendency.EditorOptions := FTendency.EditorOptions + [aOption]
    else
      FTendency.EditorOptions := FTendency.EditorOptions - [aOption];
  end;
begin
  FTendency.EditorOptions := [];
  FTendency.OverrideEditorOptions := OverrideOptionsChk.Checked;
  FTendency.TabWidth := StrToIntDef(TabWidthEdit.Text, 4);
  FTendency.TabsSpecialFiles := TabsSpecialEdit.Text;
  SetFlag(eoTabsToSpaces, TabsToSpacesChk.Checked);
end;

procedure TTendencyForm.RetrieveFrames;
var
  TabSheet: TTabSheet;
  i: Integer;
begin
  Caption := Caption + ' [' + FTendency.Name + ']';
  FTendency.CreateOptionsFrame(Self, FTendency, @AddFrame);

  for i := 0 to Length(FFrames) - 1 do
  begin
    TabSheet := PageControl.AddTabSheet;
    TabSheet.Caption := FFrames[i].Caption;

    FFrames[i].Parent := TabSheet;
    FFrames[i].Align := alClient;
    FFrames[i].Visible := True;
    if Supports(FFrames[i], IEditorOptions) then
      (FFrames[i] as IEditorOptions).Retrieve;
  end;
end;

procedure TTendencyForm.Retrieve;
begin
  //Add any new overrided options to cSynOverridedOptions in EditorProfiles unit
  OverrideOptionsChk.Checked := FTendency.OverrideEditorOptions;
  TabWidthEdit.Text := IntToStr(FTendency.TabWidth);
  TabsToSpacesChk.Checked := eoTabsToSpaces in FTendency.EditorOptions;
  TabsSpecialEdit.Text := FTendency.TabsSpecialFiles;
end;

procedure TTendencyForm.PageControlChanging(Sender: TObject; var AllowChange: Boolean);
begin
  if not (csLoading in ComponentState) then //When createing the form when do not need to trigger
    if (PageControl.ActivePage = GeneralSheet) then
      Apply;
end;

procedure TTendencyForm.AddFrame(AFrame: TFrame);
begin
  SetLength(FFrames, Length(FFrames) + 1);
  FFrames[Length(FFrames)- 1] := AFrame;
end;

procedure TTendencyForm.ApplyFrames;
var
  i: Integer;
begin
  for i :=0 to Length(FFrames) - 1 do
    if Supports(FFrames[i], IEditorOptions) then
      (FFrames[i] as IEditorOptions).Apply;
end;

end.
