{*******************************************************************************
  作者: dmzn@163.com 2009-7-2
  描述: 供应商
*******************************************************************************}
unit UFramePProvider;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, Menus, dxSkinscxPCPainter, dxLayoutcxEditAdapters;

type
  TfFrameProvider = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
    FListA: TStrings;
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //创建释放
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness,
  UBusinessPacker;

class function TfFrameProvider.FrameID: integer;
begin
  Result := cFI_FrameProvider;
end;

procedure TfFrameProvider.OnCreateFrame;
begin
  inherited;
  FListA := TStringList.Create;
end;

procedure TfFrameProvider.OnDestroyFrame;
begin
  FListA.Free;
  inherited;
end;

function TfFrameProvider.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_Provider;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By P_Name';
end;

//Desc: 添加
procedure TfFrameProvider.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormProvider, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameProvider.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('P_ID').AsString;
    CreateBaseFormItem(cFI_FormProvider, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameProvider.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('P_Name').AsString;
    nStr := Format('确定要删除供应商[ %s ]吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Provider, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

//Desc: 查询
procedure TfFrameProvider.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('P_Name Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameProvider.N1Click(Sender: TObject);
begin
  inherited;
  SyncRemoteProviders;
  BtnRefresh.Click;
end;

procedure TfFrameProvider.PopupMenu1Popup(Sender: TObject);
begin
  inherited;
  {$IFDEF SyncRemote}
  N1.Visible := True;
  {$ENDIF}

  {$IFDEF MicroMsg}
  N2.Enabled := BtnEdit.Enabled;
  N3.Enabled := BtnEdit.Enabled;
  {$ELSE}
  N2.Visible := False;
  N3.Visible := False;
  {$ENDIF}
end;

procedure TfFrameProvider.N2Click(Sender: TObject);
var
  nWechartAccount:string;
  nParam: TFormCommandParam;
  nPID,nPName:string;
  nBindcustomerid:string;
  nStr:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要开通的记录', sHint);
    Exit;
  end;
  nWechartAccount := SQLQuery.FieldByName('P_WechartAccount').AsString;
  if nWechartAccount<>'' then
  begin
    ShowMsg('商城账户['+nWechartAccount+']已存在', sHint);
    Exit;
  end;
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormGetWXAccount, PopedomItem, @nParam);

  if (nParam.FCommand <> cCmd_ModalResult) or (nParam.FParamA <> mrOK) then Exit;

  nBindcustomerid  := nParam.FParamB;
  nWechartAccount := nParam.FParamC;
  nPID      := SQLQuery.FieldByName('P_ID').AsString;
  nPName    := SQLQuery.FieldByName('P_Name').AsString;

  with FListA do
  begin
    Clear;
    Values['Action']   := 'add';
    Values['BindID']   := nBindcustomerid;
    Values['Account']  := nWechartAccount;
    Values['CusID']    := nPID;
    Values['CusName']  := nPName;
    Values['Memo']     := sFlag_Provide;
  end;

  if edit_shopclients(PackerEncodeStr(FListA.Text)) <> sFlag_Yes then Exit;
  //call remote
  nStr := 'update %s set P_WechartAccount=''%s'' where P_ID=''%s''';
  nStr := Format(nStr,[sTable_Provider,nWechartAccount,nPID]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nStr);
    FDM.ADOConn.CommitTrans;
    ShowMsg('供应商 [ '+nPName+' ] 关联商城账户成功！',sHint);
    InitFormData(FWhere);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('关联商城账户失败', '未知错误');
  end;
end;

procedure TfFrameProvider.N3Click(Sender: TObject);
var
  nWechartAccount:string;
  nPID:string;
  nStr:string;
  nPName:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要取消的记录', sHint);
    Exit;
  end;
  nWechartAccount := SQLQuery.FieldByName('P_WechartAccount').AsString;
  if nWechartAccount='' then
  begin
    ShowMsg('商城账户不存在', sHint);
    Exit;
  end;

  nPID := SQLQuery.FieldByName('P_ID').AsString;
  nPName := SQLQuery.FieldByName('P_Name').AsString;

  with FListA do
  begin
    Clear;
    Values['Action']   := 'del';
    Values['Account']  := nWechartAccount;
    Values['CusID']    := nPID;
    Values['CusName']  := nPName;
    Values['Memo']     := sFlag_Provide;
  end;

  if edit_shopclients(PackerEncodeStr(FListA.Text)) <> sFlag_Yes then Exit;
  //call remote

  nStr := 'update %s set P_WechartAccount='''' where P_ID=''%s''';
  nStr := Format(nStr,[sTable_Provider,nPID]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nStr);
    FDM.ADOConn.CommitTrans;
    ShowMsg('供应商 [ '+nPName+' ] 取消商城账户关联 成功！',sHint);
    InitFormData(FWhere);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('取消商城账户关联 失败', '未知错误');
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameProvider, TfFrameProvider.FrameID);
end.
