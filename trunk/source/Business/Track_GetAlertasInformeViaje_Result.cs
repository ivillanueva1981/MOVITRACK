//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace BusinessEntities
{
    using System;
    
    public partial class Track_GetAlertasInformeViaje_Result
    {
        public int Id { get; set; }
        public Nullable<System.DateTime> FechaInicioAlerta { get; set; }
        public Nullable<System.DateTime> FechaHoraCreacion { get; set; }
        public Nullable<int> LocalDestino { get; set; }
        public string TextFechaCreacion { get; set; }
        public string PatenteTracto { get; set; }
        public string PatenteTrailer { get; set; }
        public string Velocidad { get; set; }
        public string Latitud { get; set; }
        public string Longitud { get; set; }
        public string DescripcionAlerta { get; set; }
        public Nullable<int> Ocurrencia { get; set; }
        public string Puerta1 { get; set; }
        public string Temp1 { get; set; }
        public string Observaciones { get; set; }
        public Nullable<int> ZoneLocation { get; set; }
    }
}