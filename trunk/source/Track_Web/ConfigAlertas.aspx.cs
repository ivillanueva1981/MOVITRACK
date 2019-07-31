using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using UtilitiesLayer;

namespace Track_Web
{
  public partial class ConfigAlertas : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);
    }
  }
}