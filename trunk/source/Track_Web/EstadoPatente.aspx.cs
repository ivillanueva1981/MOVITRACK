using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Track_Web
{
  public partial class EstadoPatente : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      UtilitiesLayer.Utilities.VerifyLoginStatus(Session, Response);
    }
  }
}