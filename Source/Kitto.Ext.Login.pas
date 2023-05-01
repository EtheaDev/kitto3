{-------------------------------------------------------------------------------
   Copyright 2012-2023 Ethea S.r.l.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-------------------------------------------------------------------------------}

unit Kitto.Ext.Login;

{$I Kitto.Defines.inc}

interface

uses
  SysUtils
  , EF.Tree
  , Ext.Base
  , Ext.Form
  , Kitto.Ext.Base
  , Kitto.Ext.BorderPanel
  ;

type
  /// <summary>
  ///  A form that asks for user name and password and tries to authenticate
  ///  the user.
  /// </summary>
  TKExtLoginPanel = class(TKExtBorderPanelController)
  private
    FUserName: TExtFormTextField;
    FPassword: TExtFormTextField;
    FLanguage: TExtFormComboBox;
    FLocalStorageEnabled: TExtFormCheckbox;
    FResetPasswordLink: TExtBoxComponent;
    FRegisterNewUserLink: TExtBoxComponent;
    FPrivacyPolicyLink: TExtBoxComponent;
    FLoginButton: TKExtButton;
    FStatusBar: TKExtStatusBar;
    FLocalStorageMode: string;
    FLocalStorageAskUser: Boolean;
    FResetPasswordNode: TEFNode;
    FRegisterNewUserNode: TEFNode;
    FPrivacyPolicyNode: TEFNode;
    function GetEnableButtonJS: string;
    function GetSubmitJS: string;
    function GetCheckCapsLockJS: string;
    //function ReplaceMacros(const ACode: string): string;
    function GetLocalStorageSaveJSCode(const AMode: string; const AAskUser: Boolean): string;
    function GetLocalStorageRetrieveJSCode(const AMode: string; const AAutoLogin: Boolean): string;
    function StartEnableTask: TExtExpression;
    function StopEnableTask: TExtExpression;
  strict protected
    procedure DoDisplay; override;
  public
  //published
    procedure DoLogin;
    procedure DoResetPassword;
    procedure DoRegisterNewUser;
    procedure DoPrivacyPolicy;
  end;

  /// <summary>
  ///  Logs the current user out ending the current session.
  ///  Only useful if authentication is enabled.
  /// </summary>
  TKExtLogoutController = class(TKExtToolController)
  protected
    procedure ExecuteTool; override;
  public
    /// <summary>
    ///  Returns the display label to use by default when not specified
    ///  at the view or other level. Called through RTTI.
    /// </summary>
    class function GetDefaultDisplayLabel: string;

    /// <summary>
    ///  Returns the image name to use by default when not specified at
    ///  the view or other level. Called through RTTI.
    /// </summary>
    class function GetDefaultImageName: string; override;
  end;

implementation

uses
  Math
  , StrUtils
  , NetEncoding
  , EF.Classes
  , EF.Localization
  , EF.Macros
  , Kitto.JS
  , Kitto.Types
  , Kitto.Config.Defaults
  , Kitto.Web.Application
  , Kitto.Web.Request
  , Kitto.Web.Response
  , Kitto.Web.Session
  , Kitto.JS.Controller
  , Kitto.JS.Types
  ;

{ TKExtLoginPanel }

procedure TKExtLoginPanel.DoDisplay;
const
  STANDARD_WIDTH = 236; //380;
  STANDARD_HEIGHT = 86; //130;
  CONTROL_HEIGHT = 20;
  STANDARD_EDIT_WIDTH = 96;
  STANDARD_LABEL_WIDTH = 100;
var
  LWidth, LHeight: Integer;
  LFormPanel: TExtFormFormPanel;
  LFormPanelBodyStyle: string;
  LTitle: TEFNode;
  LLocalStorageAskUserDefault: Boolean;
  LLocalStorageAutoLogin: Boolean;
  LLocalStorageOptions: TEFNode;
  LLoginHandler: TJSAjaxCall;
  LResetPasswordClickCode, LRegisterNewUserClickCode, LPrivacyPolicyClickCode: string;
  LLabelWidth, LEditWidth: Integer;
  LExtraHeight: Integer;
  LInputStyle, LResetPasswordStyle, LRegisterNewUserStyle, LPrivacyPolicyStyle, LButtonStyle: string;

  procedure AddLinkAsHRef(const ANodeName, ANodeLabel: string; var ANode: TEFNode;
    var ALink: TExtBoxComponent; AJSProcedure: TJSProcedure);
  var
    LStyle, LClickCode: string;
  begin
    ANode := Config.FindNode(ANodeName);
    if Assigned(ANode) and ANode.AsBoolean then
    begin
      LStyle := ANode.GetString('HrefStyle');
      ALink := TExtBoxComponent.CreateAndAddToArray(LFormPanel.Items);
      ALink.Padding := Format('0 0 %0:dpx 0', [TKDefaults.GetSingleSpacing]);
      LClickCode := GetJSCode(
        procedure
        begin
          TKWebResponse.Current.Items.AjaxCallMethod(Self).SetMethod(AJSProcedure);
        end);
      ALink.Html := Format(
        '<div style="text-align:right;"><a href="#" onclick="%s">%s</a></div>',
        [TNetEncoding.HTML.Encode(LClickCode),
         TNetEncoding.HTML.Encode(_(ANodeLabel))]);
      ALink.Width := LEditWidth + LLabelWidth;
      if LStyle <> '' then
        ALink.Style := LStyle;
      Inc(LHeight, CONTROL_HEIGHT + TKDefaults.GetSingleSpacing);
    end
    else
      ALink := nil;
  end;

  function GetHorizontalMargin: Integer;
  begin
    if Maximized then
      Result := TKWebSession.Current.ViewportWidth div 4
    else
      Result := 20;
  end;

begin
  inherited;
  Closable := False;
  Resizable := False;
  LTitle := Config.FindNode('Title');
  if Assigned(LTitle) then
    Title := _(LTitle.AsExpandedString)
  else
    Title := _(TKWebApplication.Current.Config.AppTitle);
  Draggable := View.GetBoolean('Controller/Movable', False);
  Maximized := TKWebRequest.Current.IsMobileBrowser;
  Border := not Maximized;
  LHeight := STANDARD_HEIGHT;
  if Maximized then
    LWidth := TKWebSession.Current.ViewportWidth
  else
    LWidth := Max(Config.GetInteger('ExtraWidth'), STANDARD_WIDTH);

  LFormPanel := TExtFormFormPanel.CreateAndAddToArray(Items);
  LFormPanel.Region := 'center';
  LLabelWidth := Config.GetInteger('FormPanel/LabelWidth', STANDARD_LABEL_WIDTH);
  LFormPanel.LabelWidth := LLabelWidth;
  LFormPanelBodyStyle := Config.GetString('FormPanel/BodyStyle');
  if LFormPanelBodyStyle <> '' then
    LFormPanel.BodyStyle := LFormPanelBodyStyle;
  LFormPanel.MonitorValid := True;
  LFormPanel.LabelAlign := laRight;
  LFormPanel.Border := False;
  LFormPanel.Frame := False;
  LFormPanel.AutoScroll := True;


  FStatusBar := TKExtStatusBar.Create(LFormPanel);
  FStatusBar.DefaultText := '';
  FStatusBar.StatusAlign := Config.GetString('FormPanel/StatusAlign', 'left');
  FStatusBar.BusyText := _('Logging in...');
  LFormPanel.Bbar := FStatusBar;

  FLoginButton := TKExtButton.CreateAndAddToArray(FStatusBar.Items);
  FLoginButton.SetIconAndScale('login', 'medium');
  FLoginButton.Text := _('Login');
  LButtonStyle := Config.GetString('FormPanel/ButtonStyle');
  if LButtonStyle <> '' then
    FLoginButton.Style := LButtonStyle;

  LFormPanel.BodyPadding := '10px 0 0 0';
  LEditWidth := Config.GetInteger('EditWidth',
    Max(LWidth - LLabelWidth - GetHorizontalMargin * 2, STANDARD_EDIT_WIDTH));

  FUserName := TExtFormTextField.CreateAndAddToArray(LFormPanel.Items);
  FUserName.Name := 'UserName';
  FUserName.Value := TKWebSession.Current.AuthData.GetExpandedString('UserName');
  FUserName.FieldLabel := Config.GetString('FormPanel/UserName',_('User Name'));
  FUserName.AllowBlank := False;
  FUserName.EnableKeyEvents := True;
  FUserName.SelectOnFocus := True;
  FUserName.Width := LEditWidth + LLabelWidth;
  LInputStyle := Config.GetString('FormPanel/InputStyle');
  if LInputStyle <> '' then
    FUserName.Style := LInputStyle;
  Inc(LHeight, CONTROL_HEIGHT + TKDefaults.GetSingleSpacing);

  FPassword := TExtFormTextField.CreateAndAddToArray(LFormPanel.Items);
  FPassword.Name := 'Password';
  FPassword.Value := TKWebSession.Current.AuthData.GetExpandedString('Password');
  FPassword.FieldLabel := Config.GetString('FormPanel/Password',_('Password'));
  FPassword.InputType := itPassword;
  FPassword.AllowBlank := False;
  FPassword.EnableKeyEvents := True;
  FPassword.SelectOnFocus := True;
  FPassword.Width := LEditWidth + LLabelWidth;
  if LInputStyle <> '' then
    FPassword.Style := LInputStyle;
  Inc(LHeight, CONTROL_HEIGHT + TKDefaults.GetSingleSpacing);

  FUserName.On('specialkey', GenerateAnonymousFunction('field, e', GetSubmitJS));
  FPassword.On('specialkey', GenerateAnonymousFunction('field, e', GetSubmitJS));
  FPassword.On('keydown', GenerateAnonymousFunction(GetCheckCapsLockJS));

  StartEnableTask;

  if TKWebApplication.Current.Config.LanguagePerSession then
  begin
    FLanguage := TExtFormComboBox.CreateAndAddToArray(LFormPanel.Items);
    // Don't call JSArray on the window, as it will generate a dependency cycle.
	{ TODO: Verify if this still holds true }
    FLanguage.StoreArray := FLanguage.JSArray('["it", "Italiano"], ["en", "English"]');
    FLanguage.HiddenName := 'Language';
    FLanguage.Value := TKWebSession.Current.AuthData.GetExpandedString('Language');
    if FLanguage.Value = '' then
      FLanguage.Value := TKWebApplication.Current.Config.Config.GetString('LanguageId');
    FLanguage.FieldLabel := Config.GetString('FormPanel/Language',_('Language'));
    //FLanguage.EnableKeyEvents := True;
    //FLanguage.SelectOnFocus := True;
    FLanguage.ForceSelection := True;
    FLanguage.TriggerAction := 'all'; // Disable filtering list items based on current value.
    FLanguage.Width := LEditWidth + LFormPanel.LabelWidth;
    if LInputStyle <> '' then
      FLanguage.Style := LInputStyle;

    Inc(LHeight, CONTROL_HEIGHT + TKDefaults.GetSingleSpacing);
  end
  else
    FLanguage := nil;

  LLocalStorageOptions := Config.FindNode('LocalStorage');
  if Assigned(LLocalStorageOptions) then
  begin
    FLocalStorageMode := LLocalStorageOptions.GetString('Mode');
    FLocalStorageAskUser := LLocalStorageOptions.GetBoolean('AskUser');
    LLocalStorageAskUserDefault := LLocalStorageOptions.GetBoolean('AskUser/Default', True);
    LLocalStorageAutoLogin := LLocalStorageOptions.GetBoolean('AutoLogin', False);
  end
  else
  begin
    FLocalStorageMode := '';
    FLocalStorageAskUser := False;
    LLocalStorageAskUserDefault := False;
    LLocalStorageAutoLogin := False;
  end;

  if (FLocalStorageMode <> '') and FLocalStorageAskUser then
  begin
    FLocalStorageEnabled := TExtFormCheckbox.CreateAndAddToArray(LFormPanel.Items);
    FLocalStorageEnabled.Name := 'LocalStorageEnabled';
    FLocalStorageEnabled.Checked := LLocalStorageAskUserDefault;
    if SameText(FLocalStorageMode, 'Password') then
      FLocalStorageEnabled.FieldLabel := Config.GetString('FormPanel/RememberCredentials',_('Remember Credentials'))
    else
      FLocalStorageEnabled.FieldLabel := Config.GetString('FormPanel/RememberUserName', _('Remember User Name'));
    Inc(LHeight, CONTROL_HEIGHT + TKDefaults.GetSingleSpacing);
  end
  else
    FLocalStorageEnabled := nil;

  AddLinkAsHRef('ResetPassword', 'Password forgotten?',
    FResetPasswordNode, FResetPasswordLink, DoResetPassword);

  AddLinkAsHRef('RegisterNewUser', 'New User? Register...',
    FRegisterNewUserNode, FRegisterNewUserLink, DoRegisterNewUser);

  AddLinkAsHRef('PrivacyPolicy', 'Privacy policy...',
    FPrivacyPolicyNode, FPrivacyPolicyLink, DoPrivacyPolicy);

  LLoginHandler := TKWebResponse.Current.Items.AjaxCallMethod(Self).SetMethod(DoLogin)
    .AddParam('Dummy1', FStatusBar.ShowBusy)
    .AddParam('Dummy2', FLoginButton.Disable)
    .AddParam('Dummy3', StopEnableTask)
    .AddParam('UserName', FUserName.GetValue)
    .AddParam('Password', FPassword.GetValue)
    .AddParam('UserName', FUserName.GetValue);
  if Assigned(FLanguage) then
    LLoginHandler.AddParam('Language', FLanguage.GetValue);
  if Assigned(FLocalStorageEnabled) then
    LLoginHandler.AddParam('LocalStorageEnabled', FLocalStorageEnabled.GetValue);
  FLoginButton.Handler := LLoginHandler.AsFunction;

  if Assigned(FLanguage) then
    FLoginButton.Disabled := (FUserName.Value = '') or (FPassword.Value = '') or (FLanguage.Value = '')
  else
    FLoginButton.Disabled := (FUserName.Value = '') or (FPassword.Value = '');

  if (FUserName.Value <> '') and (FPassword.Value = '') then
    FPassword.Focus(False, 750)
  else
    FUserName.Focus(False, 750);

  &On('render', GenerateAnonymousFunction(GetLocalStorageRetrieveJSCode(FLocalStorageMode, LLocalStorageAutoLogin)));

  LExtraHeight := Config.GetInteger('ExtraHeight');
  Height := LHeight + LExtraHeight;
  Width := LWidth;

  //if TKWebRequest.Current.IsMobileBrowser then
//    DisplayMode := 'FullScreen';
end;

function TKExtLoginPanel.GetEnableButtonJS: string;
begin
  Result := Format(
    '%s.setDisabled(%s.getValue() == "" || %s.getValue() == "");',
    [FLoginButton.JSName, FUserName.JSName, FPassword.JSName]);
end;

function TKExtLoginPanel.GetSubmitJS: string;
begin
  Result := Format(
    // For some reason != does not survive rendering.
    'if (e.getKey() == 13 && !(%s.getValue() == "") && !(%s.getValue() == "")) %s.handler.call(%s.scope, %s);',
    [FUserName.JSName, FPassword.JSName, FLoginButton.JSName, FLoginButton.JSName, FLoginButton.JSName]);
end;

(*
function TKExtLoginPanel.ReplaceMacros(const ACode: string): string;
begin
  Result := ACode;
  Result := ReplaceStr(Result, '%STATUSBAR%', FStatusBar.JSName);
  Result := ReplaceStr(Result, '%CAPS_ON%', _('Caps On'));
end;
*)

function TKExtLoginPanel.GetCheckCapsLockJS: string;
begin
(*
  Result := ReplaceMacros(
    'if (event.keyCode !== 13 && event.getModifierState("CapsLock")) ' +
    '{%STATUSBAR%.setText(''%CAPS_ON%''); %STATUSBAR%.setIcon('''');} ' +
    'else {%STATUSBAR%.setText('''');}');
*)
end;

function TKExtLoginPanel.StartEnableTask: TExtExpression;
begin
  Result := TKWebResponse.Current.Items.ExecuteJSCode(Self, Format(
    '%s.enableTask = Ext.TaskManager.start({ ' + sLineBreak +
    '  run: function() {' + GetEnableButtonJS + '},' + sLineBreak +
    '  interval: 500});', [JSName])).AsExpression;
end;

function TKExtLoginPanel.StopEnableTask: TExtExpression;
begin
  Result := TKWebResponse.Current.Items.ExecuteJSCode(Format('Ext.TaskManager.stop(%s.enableTask);', [JSName])).AsExpression;
end;

procedure TKExtLoginPanel.DoLogin;
begin
  if TKWebApplication.Current.Authenticate then
  begin
    TKWebResponse.Current.Items.ExecuteJSCode(GetLocalStorageSaveJSCode(FLocalStorageMode, FLocalStorageAskUser));
    Close;
    NotifyObservers('LoggedIn');
  end
  else
  begin
    FStatusBar.SetErrorStatus(_('Invalid login.'));
    FPassword.Focus(False, 750);
    FLoginButton.Disabled := False;
    StartEnableTask;
  end;
end;

procedure TKExtLoginPanel.DoPrivacyPolicy;
begin
  Assert(Assigned(FPrivacyPolicyNode));

  { TODO : Add a way to open standard/system views without needing to store them in a yaml file.
    Maybe a json definition passed as a string? }
  TKWebApplication.Current.DisplayView('PrivacyPolicy');
end;

procedure TKExtLoginPanel.DoRegisterNewUser;
begin
  Assert(Assigned(FRegisterNewUserLink));

  { TODO : Add a way to open standard/system views without needing to store them in a yaml file.
    Maybe a json definition passed as a string? }
  TKWebApplication.Current.DisplayView('RegisterNewUser');
end;

procedure TKExtLoginPanel.DoResetPassword;
begin
  Assert(Assigned(FResetPasswordNode));

  { TODO : Add a way to open standard/system views without needing to store them in a yaml file.
    Maybe a json definition passed as a string? }
  TKWebApplication.Current.DisplayView('ResetPassword');
end;

function TKExtLoginPanel.GetLocalStorageSaveJSCode(const AMode: string; const AAskUser: Boolean): string;

  function IfChecked: string;
  begin
    if Assigned(FLocalStorageEnabled) then
      Result := 'if (' + FLocalStorageEnabled.JSName + '.getValue())'
    else
      Result := 'if (true)';
  end;

  function GetDeleteCode: string;
  begin
    Result := 'delete localStorage.' + TKWebApplication.Current.Config.AppName + '_UserName;' + sLineBreak;
    Result := Result + 'delete localStorage.' + TKWebApplication.Current.Config.AppName + '_Password;' + sLineBreak;
    Result := Result + 'delete localStorage.' + TKWebApplication.Current.Config.AppName + '_LocalStorageEnabled;' + sLineBreak;
  end;

begin
  Result := '';
  if (AMode <> '') then
  begin
    Result := Result + IfChecked + '{';
    if SameText(AMode, 'UserName') or SameText(AMode, 'Password') then
      Result := Result + 'localStorage.' + TKWebApplication.Current.Config.AppName + '_UserName = "' + ParamAsString('UserName') + '";';
    if SameText(AMode, 'Password') then
      Result := Result + 'localStorage.' + TKWebApplication.Current.Config.AppName + '_Password = "' + ParamAsString('Password') + '";';
    if AAskUser then
      Result := Result + 'localStorage.' + TKWebApplication.Current.Config.AppName + '_LocalStorageEnabled = "' + ParamAsString('LocalStorageEnabled') + '";';
    Result := Result + '} else {' + GetDeleteCode + '};';
  end
  else
    Result := GetDeleteCode;
end;

function TKExtLoginPanel.GetLocalStorageRetrieveJSCode(const AMode: string; const AAutoLogin: Boolean): string;
begin
  if SameText(AMode, 'UserName') or SameText(AMode, 'Password') then
    Result := Result + 'var u = localStorage.' + TKWebApplication.Current.Config.AppName + '_UserName; if (u) ' + FUserName.JSName + '.setValue(u);';
  if SameText(AMode, 'Password') then
    Result := Result + 'var p = localStorage.' + TKWebApplication.Current.Config.AppName + '_Password; if (p) ' + FPassword.JSName + '.setValue(p);';
  if Assigned(FLocalStorageEnabled) then
    Result := Result + 'var l = localStorage.' + TKWebApplication.Current.Config.AppName + '_LocalStorageEnabled; if (l) ' + FLocalStorageEnabled.JSName + '.setValue(l);';
  if AAutoLogin then
    Result := Result + Format('setTimeout(function(){ %s.getEl().dom.click(); }, 100);', [FLoginButton.JSName]);
end;

{ TKExtLogoutController }

procedure TKExtLogoutController.ExecuteTool;
begin
  inherited;
  TKWebApplication.Current.Logout;
end;

class function TKExtLogoutController.GetDefaultDisplayLabel: string;
begin
  Result := _('Logout');
end;

class function TKExtLogoutController.GetDefaultImageName: string;
begin
  Result := 'logout';
end;

initialization
  TKExtControllerRegistry.Instance.RegisterClass('Login', TKExtLoginPanel);
  TKExtControllerRegistry.Instance.RegisterClass('Logout', TKExtLogoutController);

finalization
  TKExtControllerRegistry.Instance.UnregisterClass('Login');
  TKExtControllerRegistry.Instance.UnregisterClass('Logout');

end.
