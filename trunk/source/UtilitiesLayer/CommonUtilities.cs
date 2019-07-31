using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;

using System.Xml.Serialization;
using System.IO;
using System.Xml;
using System.Xml.Xsl;
using System.Reflection;
using System.Data;
using System.ComponentModel;
using System.Configuration;

namespace CrossCutting
{
  /// <summary>
  /// Utilidades y funciones centralizadas.
  /// </summary>
  public static class CommonUtilities
  {
    #region Logs Info

    private static string InfoFile = string.Format("WSInformacion_LogInfo{0}.Log", DateTime.Now.ToString("yyyyMMdd"));
    private static string ErrFile = string.Format("WSInformacion_LogError{0}.Log", DateTime.Now.ToString("yyyyMMdd"));
    private static string _logFolder;

    public enum EventType
    {
      Information,
      Warning,
      Error
    }

    #endregion

    #region Logeo de Excepciones y Mensajes

    private static FileStream Logfile;

    /// Ruta completa del archivo de Log.
    private static string LogFilePath = string.Empty;

    /// Logea la excepción enviada en un archivo local de la carpeta de ejecución del sistema.
    public static void ExceptionLog(string source, Exception ex)
    {
      string message = GetLogExceptionInformation(ex);

      /* Escribe el mensaje generado en el Log */
      MessageLog(source, message);
    }

    /// Logea la excepción enviada en un archivo local de la carpeta de ejecución del sistema.
    public static void MessageLog(string source, string message)
    {
      FileStream file = GetLogFile();

      StreamWriter stream = new StreamWriter(file);
      stream.WriteLine("{0} :: {1} \r\n\t{2}", DateTime.Now.ToString("dd/MM/yyy HH:mm:ss"), source, message);

      /* Volcado del buffer y cierre del archivo */
      stream.Flush();

    }

    /// Genera el detalle de la excepción en un string para su logeo.
    private static string GetLogExceptionInformation(Exception ex)
    {
      StringBuilder sb = new StringBuilder();

      /* Agrega información de la excepción */
      sb.AppendLine(string.Format("Exception : {0}", ex.GetType().Name));
      sb.AppendLine(string.Format("\tMessage :{0}", ex.Message));
      sb.AppendLine(string.Format("\tStackTrace : {0}", ex.StackTrace));

      /* Agrega información de la excepción anidada de manera recursiva */
      if (ex.InnerException != null)
      {
        sb.Append(GetLogExceptionInformation(ex.InnerException));
      }

      return sb.ToString();
    }

    /// Retorna el FileSteam asociado al archivo de log de la aplicación.
    private static FileStream GetLogFile()
    {
      /* Si no se ha creado el archivo se debe abrir/crear el archivo de log */
      if (Logfile == null)
      {
        string fileName = GetLogPath();

        if (File.Exists(fileName))
        {
          Logfile = new FileStream(
              fileName,               //Ruta del Archivo
              FileMode.Append,        //Abre el archivo para agregar información
              FileAccess.Write,       //Permiso de escritura
              FileShare.ReadWrite     //Compartido para lectura y escritura (no queda bloqueado)
                                   );
        }
        else
        {
          Logfile = new FileStream(
              fileName,               //Ruta del Archivo
              FileMode.OpenOrCreate,  //Abre o crea un nuevo archivo
              FileAccess.Write,       //Permiso de escritura
              FileShare.ReadWrite     //Compartido para lectura y escritura (no queda bloqueado)
                                   );
          Logfile.Position = Logfile.Length;

        }
      }

      return Logfile;
    }

    /// Genera la ruta del archivo de Log acorde a la plataforma de ejecución
    private static string GetLogPath()
    {
      if (string.IsNullOrEmpty(LogFilePath))
      {
        string pathFile = string.Empty;
        pathFile = Path.GetDirectoryName(Assembly.GetExecutingAssembly().GetName().CodeBase);

        Uri uriPath = new Uri(pathFile, UriKind.Absolute);
        pathFile = Uri.UnescapeDataString(uriPath.AbsolutePath);

        /* Completa con el nombre del archivo */
        LogFilePath = Path.Combine(pathFile, string.Format("_WSInformacion_{0}_{1}.log", DateTime.Now.Year, DateTime.Now.Month.ToString("D2")));
      }

      return LogFilePath;
    }

    /// Convierte lista a DataTable
    public static DataTable ConvertToDataTable<T>(IList<T> data)
    {
      PropertyDescriptorCollection properties = TypeDescriptor.GetProperties(typeof(T));
      DataTable table = new DataTable();
      foreach (PropertyDescriptor prop in properties)
        table.Columns.Add(prop.Name, Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType);
      foreach (T item in data)
      {
        DataRow row = table.NewRow();
        foreach (PropertyDescriptor prop in properties)
          row[prop.Name] = prop.GetValue(item) ?? DBNull.Value;
        table.Rows.Add(row);
      }
      return table;
    }

    /// Escribe info en log de error.
    public static void WriteInfo(string message, string error, EventType eventType, string logFolder, bool logInfo)
    {
      _logFolder = logFolder;
      checkSource();

      StreamWriter fs = null;

      try
      {
        switch (eventType)
        {
          case EventType.Warning:
          case EventType.Information:

            if (!logInfo)
            { return; }

            fs = new StreamWriter(Path.Combine(_logFolder, InfoFile), true);
            break;
          case EventType.Error:
            fs = new StreamWriter(Path.Combine(_logFolder, ErrFile), true);
            break;
        }

        StringBuilder sb = new StringBuilder();
        sb.AppendLine("=================================================================================================");
        sb.AppendLine(string.Format("Fecha: {0}, Hora: {1}", DateTime.Now.ToShortDateString(), DateTime.Now.ToLongTimeString()));
        sb.AppendLine("_________________________________________________________________________________________________");

        if (error != null)
        {
          sb.AppendLine(string.Format("<Exception>: {0}", error));
        }

        sb.AppendLine("                                                                                                 ");
        if (message != null)
        {
          sb.AppendLine(string.Format("<XML_Recibido>: {0}", message));
        }

        sb.AppendLine("=================================================================================================");

        fs.WriteLine(sb.ToString());
      }
      finally
      {
        if (fs != null)
        {
          fs.Close();
          fs = null;
        }
      }
    }

    /// Escribe info en log.
    public static void WriteInfo(string message, EventType eventType, string logFolder, bool logInfo)
    {
      _logFolder = logFolder;
      checkSource();

      StreamWriter fs = null;

      try
      {
        switch (eventType)
        {
          case EventType.Warning:
          case EventType.Information:

            if (!logInfo)
            { return; }
            fs = new StreamWriter(Path.Combine(_logFolder, InfoFile), true);
            break;
          case EventType.Error:
            fs = new StreamWriter(Path.Combine(_logFolder, ErrFile), true);
            break;
        }

        StringBuilder sb = new StringBuilder();
        sb.AppendLine("=================================================================================================");
        sb.AppendLine(string.Format("Fecha: {0}, Hora: {1}", DateTime.Now.ToShortDateString(), DateTime.Now.ToLongTimeString()));
        sb.AppendLine("_________________________________________________________________________________________________");
        sb.AppendLine(string.Format(message));
        sb.AppendLine("=================================================================================================");

        fs.WriteLine(sb.ToString());
      }
      finally
      {
        if (fs != null)
        {
          fs.Close();
          fs.Dispose();
          fs = null;
        }
      }
    }

    /// Analiza si directorio o ruta en la que se escribiá log existe.
    private static void checkSource()
    {
      //_logFolder = Path.Combine(SystemRootDriver(), _logFolder);

      if (!Directory.Exists(_logFolder))
      {
        Directory.CreateDirectory(_logFolder);
      }

      if (!File.Exists(Path.Combine(_logFolder, InfoFile)))
      {
        using (FileStream f = new FileStream(Path.Combine(_logFolder, InfoFile), FileMode.Create))
        {

        }
      }
      if (!File.Exists(Path.Combine(_logFolder, ErrFile)))
      {
        using (FileStream f = new FileStream(Path.Combine(_logFolder, ErrFile), FileMode.Create))
        { }
      }
    }

    public static string SystemRootDriver()
    {
      string sysDir = Environment.SystemDirectory;
      DirectoryInfo dInf = new DirectoryInfo(sysDir);

      return dInf.Root.Name;
    }

    public static void WriteInfo(string message, string logFolder, bool logInfo)
    {
      _logFolder = logFolder;
      checkSource();

      StreamWriter fs = null;

      try
      {
        if (!logInfo)
        { return; }
        fs = new StreamWriter(Path.Combine(_logFolder, InfoFile), true);

        StringBuilder sb = new StringBuilder();
        sb.AppendLine("=================================================================================================");
        sb.AppendLine(string.Format("Fecha: {0}, Hora: {1}", DateTime.Now.ToShortDateString(), DateTime.Now.ToLongTimeString()));
        sb.AppendLine("_________________________________________________________________________________________________");
        sb.AppendLine(string.Format(message));
        sb.AppendLine("=================================================================================================");

        fs.WriteLine(sb.ToString());
      }
      finally
      {
        if (fs != null)
        {
          fs.Close();
          fs.Dispose();
          fs = null;
        }
      }
    }

    #endregion

  }
}
