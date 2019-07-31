<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Track_Web._Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>

<script type="text/javascript">

Ext.onReady(function () {

    Ext.QuickTips.init();
    Ext.form.Field.prototype.msgTarget = 'side';
    if (Ext.isIE) { Ext.enableGarbageCollector = false; }

    var centerPanel = new Ext.FormPanel({
      id: 'centerPanel',
      region: 'center',
      border: true,
      margins: '0 5 0 0',
      anchor: '100% 100%',
      html: '<img src="Images/background_gray_1366x768.png" style="height:100%; width:100%"/>'
    });

    var viewport = Ext.create('Ext.container.Viewport', {
      layout: 'border',
      items: [topMenu, centerPanel]
    });

  });

</script>
</asp:Content>