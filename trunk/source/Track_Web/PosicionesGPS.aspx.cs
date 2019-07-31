using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using UtilitiesLayer;

using BusinessEntities;
using BusinessLayer;
using Newtonsoft.Json;

namespace Track_Web
{
  public partial class PosicionesGPS : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);
    }
  }
}