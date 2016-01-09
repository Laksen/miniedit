unit EditorProfiles;
{$mode objfpc}{$H+}
{**
 * Mini Edit
 *
 * @license    GPL 2 (http://www.gnu.org/licenses/gpl.html)
 * @author    Zaher Dirkey <zaher at parmaja dot com>
 *}

{/$I SynEdit.inc}

interface

uses
  Messages, Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, Registry, ExtCtrls, Buttons, ImgList,
  mnXMLRttiProfile, SynEditMarkupWordGroup,
  Contnrs, Menus, SynEdit, SynEditHighlighter, SynEditMiscClasses, SynEditPointClasses, SynGutterCodeFolding,
  SynGutter, SynEditKeyCmds, Classes, SysUtils;

type
  TAttributeType = (
    attUI,
    attPanel,
    attURL,
    attGutter,
    attSeparator,
    attSelected,
    attModified,
    attWhitespace,
    attKeyword,
    attString,
    attDocument,
    attComment,
    attSymbol,
    attStandard,
    attNumber,
    attDirective,
    attIdentifier,
    attText,
    attOutter,
    attInner,
    attVariable,
    attType,
    attName,
    attValue
   );

const
  cSynRequiredOptions = [eoDragDropEditing, eoTrimTrailingSpaces, eoDropFiles, eoShowCtrlMouseLinks, eoAltSetsColumnMode, eoScrollPastEol, eoRightMouseMovesCursor, eoHideRightMargin];

  cSynRemoveOptions = [eoRightMouseMovesCursor, eoScrollPastEof];

  cSynOverridedOptions = [eoTabsToSpaces];

  cSynDefaultOptions = cSynRequiredOptions + cSynRemoveOptions + [eoAutoIndent, eoBracketHighlight,
    eoShowScrollHint, eoTabsToSpaces, eoTabIndent, eoTrimTrailingSpaces, eoKeepCaretX];

type
  TGlobalAttributes = class;

  { TGlobalAttribute }

  TGlobalAttribute = class(TPersistent)
  private
    FBackground: TColor;
    FForeground: TColor;
    FIndex: Integer;
    FParent: TGlobalAttributes;
    FStyle: TFontStyles;
    FAttType: TAttributeType;
    FTitle: string;
  protected
    property Parent: TGlobalAttributes read FParent;
  public
    constructor Create;
    procedure AssignTo(Dest: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    property Index: Integer read FIndex;
  published
    property Title: string read FTitle write FTitle;
    property AttType: TAttributeType read FAttType write FAttType;
    property Background: TColor read FBackground write FBackground default clNone;
    property Foreground: TColor read FForeground write FForeground default clNone;
    property Style: TFontStyles read FStyle write FStyle default [];
  end;

  { TGlobalAttributes }

  TGlobalAttributes = class(TComponent)
  private
    FFontName: String;
    FFontNoAntialiasing: Boolean;
    FFontSize: Integer;
    FInner: TGlobalAttribute;
    FOutter: TGlobalAttribute;
    FDataName: TGlobalAttribute;
    FDataType: TGlobalAttribute;
    FDirective: TGlobalAttribute;

    FDocument: TGlobalAttribute;
    FQuotedString: TGlobalAttribute;
    FIdentifier: TGlobalAttribute;
    FKeyword: TGlobalAttribute;

    FNumber: TGlobalAttribute;
    FSelected: TGlobalAttribute;
    FModified: TGlobalAttribute;
    FGutter: TGlobalAttribute;
    FSeparator: TGlobalAttribute;
    FComment: TGlobalAttribute;
    FSymbol: TGlobalAttribute;
    FText: TGlobalAttribute;
    FUI: TGlobalAttribute;
    FPanel: TGlobalAttribute;
    FURL: TGlobalAttribute;
    FValue: TGlobalAttribute;
    FVariable: TGlobalAttribute;
    FStandard: TGlobalAttribute;
    FWhitespace: TGlobalAttribute;

    FList: TObjectList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TGlobalAttribute;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reset;
    function Find(AttType: TAttributeType): TGlobalAttribute;
    property Items[Index: Integer]: TGlobalAttribute read GetItem; default;
    property Count: Integer read GetCount;
    procedure Assign(Source: TPersistent); override;
  published
    property UI: TGlobalAttribute read FUI;
    property URL: TGlobalAttribute read FURL;
    property Selected: TGlobalAttribute read FSelected;
    property Gutter: TGlobalAttribute read FGutter;
    property Separator: TGlobalAttribute read FSeparator;
    property Modified: TGlobalAttribute read FModified;
    property Whitespace: TGlobalAttribute read FWhitespace;
    property Keyword: TGlobalAttribute read FKeyword;
    property Symbol: TGlobalAttribute read FSymbol;
    property Number: TGlobalAttribute read FNumber;
    property Directive: TGlobalAttribute read FDirective;
    property Identifier: TGlobalAttribute read FIdentifier;
    property Variable: TGlobalAttribute read FVariable;
    property Standard: TGlobalAttribute read FStandard;
    property Value: TGlobalAttribute read FValue;
    property DataType: TGlobalAttribute read FDataType;
    property DataName: TGlobalAttribute read FDataName;
    property Document: TGlobalAttribute read FDocument;
    property Text: TGlobalAttribute read FText;
    property Outter: TGlobalAttribute read FOutter;
    property Inner: TGlobalAttribute read FInner;
    property Comment: TGlobalAttribute read FComment;
    property QuotedString: TGlobalAttribute read FQuotedString;
    property FontName: String read FFontName write FFontName;
    property FontSize: Integer read FFontSize write FFontSize;
    property FontNoAntialiasing: Boolean read FFontNoAntialiasing write FFontNoAntialiasing default False;
  end;

  TEditorProfile = class;
  { TGutterOptions }

  TGutterOptions = class(TPersistent)
  private
    FProfile: TEditorProfile;

    FAutoSize: boolean;
    FLeftOffset: integer;
    FRightOffset: integer;
    FShowModifiedLines: Boolean;
    FLeadingZeros: Boolean;
    FShowSeparator: Boolean;
    FWidth: Integer;
  public
    constructor Create(AProfile: TEditorProfile);
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
    constructor AssignFrom(SynGutter: TSynGutter);
    procedure Reset; virtual;
  published
    property AutoSize: boolean read FAutoSize write FAutoSize default True;
    property ShowSeparator: Boolean read FShowSeparator write FShowSeparator default True;
    property ShowModifiedLines: Boolean read FShowModifiedLines write FShowModifiedLines default True;
    property Width: integer read FWidth write FWidth default 30;
    property LeadingZeros: Boolean read FLeadingZeros write FLeadingZeros default False;
    property LeftOffset: integer read FLeftOffset write FLeftOffset default 0;
    property RightOffset: integer read FRightOffset write FRightOffset default 0;
  end;

  //This class is assignable to a SynEdit without modifying key properties that affect function

  { TEditorProfile }

  TEditorProfile = class(TmnXMLProfile)
  private
    FCodeFolding: Boolean;
    FDrawDivider: Boolean;
    FExtEditorOptions: TSynEditorOptions2;
    FMaxUndo: Integer;
    FExtraLineSpacing: Integer;
    FTabsToSpaces: Boolean;
    FTabWidth: Integer;
    FBookmarks: TSynBookMarkOpt;
    FEditorOptions: TSynEditorOptions;
    FGutterOptions: TGutterOptions;
    FAttributes: TGlobalAttributes;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
    constructor AssignFrom(SynEdit: TSynEdit);
    procedure Reset;
  published
    property Attributes: TGlobalAttributes read FAttributes;
    property EditorOptions: TSynEditorOptions read FEditorOptions write FEditorOptions default cSynDefaultOptions;
    property ExtEditorOptions: TSynEditorOptions2 read FExtEditorOptions write FExtEditorOptions default [];
    property Gutter: TGutterOptions read FGutterOptions write FGutterOptions;
    property ExtraLineSpacing: Integer read FExtraLineSpacing write FExtraLineSpacing default 0;
    property MaxUndo: Integer read FMaxUndo write FMaxUndo default 1024;
    property CodeFolding: Boolean read FCodeFolding write FCodeFolding default False;
    property DrawDivider: Boolean read FDrawDivider write FDrawDivider default False; //TODO not yet
    //Can be overriden by project options
    property TabWidth: Integer read FTabWidth write FTabWidth default 4;
  end;

implementation

uses
  SynGutterBase, SynGutterLineNumber, SynGutterChanges;

{ TEditorProfile }

constructor TEditorProfile.Create;
begin
  inherited;
  FBookmarks := TSynBookMarkOpt.Create(nil);
  FGutterOptions := TGutterOptions.Create(Self);//TODO check the Create params
  FAttributes := TGlobalAttributes.Create(nil);
  CodeFolding := False;
  DrawDivider := False;
  Reset;
end;

destructor TEditorProfile.Destroy;
begin
  FBookMarks.Free;
  FGutterOptions.Free;
  FAttributes.Free;
  inherited;
end;

procedure TEditorProfile.Assign(Source: TPersistent);
begin
  if Source is TSynEdit then
    AssignFrom(Source as TSynEdit)
  else
    inherited Assign(Source);
end;

procedure TEditorProfile.AssignTo(Dest: TPersistent);
var
  SynEdit: TSynEdit;
begin
  if Dest is TSynEdit then
  begin
    SynEdit := Dest as TSynEdit;

    SynEdit.Font.Name := Attributes.FontName;
    SynEdit.Font.Size := Attributes.FontSize;
    if Attributes.FontNoAntialiasing then
      SynEdit.Font.Quality := fqNonAntialiased
    else
      SynEdit.Font.Quality := fqDefault;

    SynEdit.Font.Color := Attributes.Whitespace.Foreground;
    SynEdit.Color := Attributes.Whitespace.Background;
    SynEdit.SelectedColor.Foreground := Attributes.Selected.Foreground;
    SynEdit.SelectedColor.Background := Attributes.Selected.Background;
    SynEdit.BracketMatchColor.Foreground := Attributes.Selected.Foreground;
    SynEdit.BracketMatchColor.Background := Attributes.Selected.Background;

    SynEdit.MarkupManager.MarkupByClass[TSynEditMarkupWordGroup].MarkupInfo.FrameColor := Attributes.Selected.Background;

    SynEdit.Options := EditorOptions + cSynRequiredOptions - cSynRemoveOptions;
    SynEdit.ExtraLineSpacing := ExtraLineSpacing;
    SynEdit.InsertCaret := ctVerticalLine;
    SynEdit.OverwriteCaret := ctBlock;
    SynEdit.MaxUndo := MaxUndo;
    SynEdit.RightEdge := 80;
    SynEdit.RightEdgeColor := clSilver;

    SynEdit.Gutter.Assign(Gutter);

    SynEdit.TabWidth := TabWidth;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TEditorProfile.AssignFrom(SynEdit: TSynEdit);
begin
end;

procedure TEditorProfile.Reset;
begin
  Attributes.Reset;
  Gutter.Reset;
  EditorOptions := cSynDefaultOptions;
  //ExtEditorOptions :=
  ExtraLineSpacing := 0;
  MaxUndo := 1024;
  TabWidth := 4;
end;

{ TGlobalAttributes }

constructor TGlobalAttributes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FComponentStyle := FComponentStyle + [csSubComponent];
  FList := TObjectList.Create(True);
  Reset;
end;

destructor TGlobalAttributes.Destroy;
begin
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TGlobalAttributes.Reset;
  procedure Add(var Item: TGlobalAttribute; AttType: TAttributeType; Title: string; Foreground, Background: TColor; Style: TFontStyles);
  begin
    Item := TGlobalAttribute.Create;
    Item.AttType := AttType;
    Item.Title := Title;
    Item.Foreground := Foreground;
    Item.Background := Background;
    Item.Style := Style;
    Item.FParent := Self;
    Item.FIndex := FList.Add(Item);
  end;

begin
  FFontName := 'Courier New';
  FFontSize := 10;
  FFontNoAntialiasing := False;

  FList.Clear;
  Add(FUI, attUI, 'User Interface', clNone, clNone, []);
  Add(FPanel, attPanel, 'Panel', clNone, clNone, []);
  Add(FURL, attURL, 'URL', clWhite, TColor($2A190F), []);

  Add(FWhitespace, attWhitespace, 'Whitespace', clWhite, TColor($2A190F), []);
  Add(FSelected, attSelected, 'Selected', clBlack, TColor($DD8B42), []);
  Add(FModified, attModified, 'Modified', clYellow, clGreen, []);
  Add(FGutter, attGutter, 'Gutter', clWhite, $4b4b4b, []);
  Add(FSeparator, attSeparator, 'Separator', clWhite, $4b4b4b, []);

  Add(FKeyword, attKeyword, 'Keyword', TColor($3737E8), clNone, []);
  Add(FQuotedString, attString, 'String', TColor($16C11D), clNone, []);
  Add(FDocument, attDocument, 'Document', TColor($DD8B42), clNone, []);
  Add(FComment, attComment, 'Comment', TColor($94541B), clNone, []);
  Add(FSymbol, attSymbol, 'Symbol', TColor($FFEDD1), clNone, []);
  Add(FStandard, attStandard, 'Standard', TColor($3EAAFF), clNone, []);
  Add(FNumber, attNumber, 'Number', TColor($0FDFEA), clNone, []);
  Add(FDirective, attDirective, 'Directive', TColor($3737E8), clNone, []);
  Add(FIdentifier, attIdentifier, 'Identifier', clNone, clNone, []);
  Add(FText, attText, 'Text', clNone, clNone, []);
  Add(FOutter, attOutter, 'Outter', TColor($DD8B42), clNone, []);
  Add(FInner, attInner, 'Inner', TColor($16C11D), clNone, []);
  Add(FVariable, attVariable, 'Variable', clSkyBlue, clNone, []);
  Add(FDataType, attType, 'Type', TColor($2f7adf), clNone, []);
  Add(FDataName, attName, 'Name', TColor($16C11D), clNone, []);
  Add(FValue, attValue, 'Value',  TColor($16C11D), clNone, []);
end;

function TGlobalAttributes.Find(AttType: TAttributeType): TGlobalAttribute;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].AttType = AttType then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

procedure TGlobalAttributes.Assign(Source: TPersistent);
var
  i: Integer;
begin
  if Source is TGlobalAttributes then
  begin
    for i := 0 to Count -1 do
      Items[i].Assign((Source as TGlobalAttributes).Items[i]);
  end
  else
    inherited Assign(Source);
end;

function TGlobalAttributes.GetItem(Index: Integer): TGlobalAttribute;
begin
  Result := FList[Index] as TGlobalAttribute;
end;

function TGlobalAttributes.GetCount: Integer;
begin
  Result := FList.Count;
end;

{ TGlobalAttribute }

procedure TGlobalAttribute.Assign(Source: TPersistent);
begin
  if Source is TSynHighlighterAttributes then
  begin
    Background := TSynHighlighterAttributes(Source).Background;
    Foreground := TSynHighlighterAttributes(Source).Foreground;
    Style := TSynHighlighterAttributes(Source).Style - [fsItalic]; //removed old font style from old version of miniedit
  end
  else if Source is TGlobalAttribute then
  begin
    Background := (Source as TGlobalAttribute).Background;
    Foreground := (Source as TGlobalAttribute).Foreground;
    Style := (Source as TGlobalAttribute).Style - [fsItalic]; //removed old font style from old version of miniedit
  end
  else
    inherited;
end;

procedure TGlobalAttribute.AssignTo(Dest: TPersistent);
begin
  if Dest is TSynHighlighterAttributes then
  begin
    TSynHighlighterAttributes(Dest).Background := Background;
    TSynHighlighterAttributes(Dest).Foreground := Foreground;
    TSynHighlighterAttributes(Dest).Style := Style - [fsItalic]; //removed old font style from old version of miniedit
  end
  else
    inherited;
end;

constructor TGlobalAttribute.Create;
begin
  inherited;
  FBackground := clNone;
  FForeground := clNone;
end;

{ TGutterOptions }

constructor TGutterOptions.Create(AProfile: TEditorProfile);
begin
  inherited Create;
  if AProfile = nil then
    raise Exception.Create('TGutterOptions should have parent profile.');
  FProfile := AProfile;
  Reset;
end;

procedure TGutterOptions.Assign(Source: TPersistent);
begin
  if Source is TSynGutter then
    AssignFrom(Source as TSynGutter)
  else
    inherited Assign(Source);
end;

procedure SetupGutter(SynGutter: TSynGutter; Attributes: TGlobalAttributes);
begin
  //TODO
end;

procedure TGutterOptions.AssignTo(Dest: TPersistent);
var
  SynGutter: TSynGutter;
  i: Integer;
  gp: TSynGutterLineNumber;
  sp: TSynGutterSeparator;
  ch: TSynGutterChanges;
  cf: TSynGutterCodeFolding;
  OldCF: Boolean;
begin
  if Dest is TSynGutter then
  begin
    SynGutter := Dest as TSynGutter;
    SynGutter.AutoSize := FAutoSize;

    SetupGutter(SynGutter, FProfile.Attributes);

    SynGutter.Color := FProfile.Attributes.Gutter.Background;
    for i := 0 to SynGutter.Parts.Count -1 do
    begin
      SynGutter.Parts[i].MarkupInfo.Foreground := FProfile.Attributes.Gutter.Foreground;
      SynGutter.Parts[i].MarkupInfo.Background := FProfile.Attributes.Gutter.Background;
    end;

    gp := SynGutter.Parts.ByClass[TSynGutterLineNumber, 0] as TSynGutterLineNumber;
    if gp <> nil then
    begin
      gp.Visible := True;
      gp.ZeroStart := False;
      gp.LeadingZeros := FLeadingZeros;
    end;

    sp := SynGutter.Parts.ByClass[TSynGutterSeparator, 0] as TSynGutterSeparator;
    if sp <> nil then
    begin
      sp.Visible := FShowSeparator;
      sp.MarkupInfo.Foreground := FProfile.Attributes.Separator.Background;
      sp.MarkupInfo.Background := FProfile.Attributes.Separator.Foreground;
    end;

    ch := SynGutter.Parts.ByClass[TSynGutterChanges, 0] as TSynGutterChanges;
    if ch <> nil then
    begin
      ch.Visible := FShowModifiedLines;
      ch.SavedColor := FProfile.Attributes.Modified.Background;
      ch.ModifiedColor := FProfile.Attributes.Modified.Foreground;
    end;

    cf := SynGutter.Parts.ByClass[TSynGutterCodeFolding, 0] as TSynGutterCodeFolding;
    if cf <> nil then
    begin
      OldCF := cf.Visible;
      cf.Visible := FProfile.CodeFolding and ((SynGutter.SynEdit as TSynEdit).Highlighter <> nil) and (hcCodeFolding in (SynGutter.SynEdit as TSynEdit).Highlighter.Capabilities);
      if (cf.Visible) and (cf.Visible <> OldCF) then
        (SynGutter.SynEdit as TSynEdit).UnfoldAll;
    end;

    SynGutter.LeftOffset := FLeftOffset;
    SynGutter.RightOffset := FRightOffset;
    SynGutter.Width := FWidth;
    SynGutter.Visible := True; //TODO
  end
  else
    inherited AssignTo(Dest);
end;

constructor TGutterOptions.AssignFrom(SynGutter: TSynGutter);
var
  gp: TSynGutterLineNumber;
  sp: TSynGutterSeparator;
  ch: TSynGutterChanges;
begin
  FAutoSize := SynGutter.AutoSize;
  FLeftOffset := SynGutter.LeftOffset;
  FRightOffset := SynGutter.RightOffset;
  FWidth := SynGutter.Width;
  gp := SynGutter.Parts.ByClass[TSynGutterLineNumber, 0] as TSynGutterLineNumber;
  if gp <> nil then
  begin
    FLeadingZeros := gp.LeadingZeros;
  end;
  sp := SynGutter.Parts.ByClass[TSynGutterSeparator, 0] as TSynGutterSeparator;
  if sp <> nil then
  begin
    FShowSeparator := sp.Visible;
  end;
  ch := SynGutter.Parts.ByClass[TSynGutterChanges, 0] as TSynGutterChanges;
  if ch <> nil then
  begin
    FShowModifiedLines := ch.Visible;
  end;
end;

procedure TGutterOptions.Reset;
begin
  FAutoSize := True;
  FShowSeparator := True;
  FLeftOffset := 0;
  FRightOffset := 0;
  FWidth := 30;
  FLeadingZeros := False;
  FShowModifiedLines := True;
end;

end.

