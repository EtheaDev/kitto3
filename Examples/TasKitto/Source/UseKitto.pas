unit UseKitto;

interface

uses
  DBXMSSQL,
  DBXFirebird,
  EF.DB.ADO,
  EF.DB.DBX,
{$IF CompilerVersion >= 27}
  EF.DB.FD, //FireDac support
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLMeta, //FireDac support for MS-SQL
  FireDAC.Phys.IBBase, FireDAC.Phys.FB, //FireDac support for Firebird
{$IFEND}
  // Kitto.AccessControl.DB,
  Kitto.Auth.DB,
  // Kitto.Auth.DBServer,
  // Kitto.Auth.OSDB,
  // Kitto.Auth.TextFile,
  {$IFDEF MSWINDOWS}
  Kitto.Ext.ADOTools, //For Excel/Import export
  Kitto.Ext.DebenuQuickPDFTools, //For PDF Merge
  //Kitto.Ext.ReportBuilderTools, //Tool for Reportbuilder
  {$ENDIF}
  //Kitto.Ext.FOPTools, //For FOP Engine
  // Kitto.Localization.dxgettext, //Commented to enable per-session localization
  Kitto.Metadata.ModelImplementation,
  Kitto.Metadata.ViewBuilders,
  Kitto.Ext.All
  ;

implementation

initialization
{$WARN SYMBOL_PLATFORM OFF}
  // check memory leaks at the end of the app
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$WARN SYMBOL_PLATFORM ON}

end.
