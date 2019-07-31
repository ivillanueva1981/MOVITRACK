function ValidarRut(rutCompleto) {
  // Valida el rut con su cadena completa "XXXXXXXX-X"
  if (!/^[0-9]+[-|‐]{1}[0-9kK]{1}$/.test(rutCompleto))
    return false;
  var tmp = rutCompleto.split('-');
  var digv = tmp[1];
  var rut = tmp[0];
  if (digv == 'K') digv = 'k';
  return (dv(rut) == digv);
}

function dv(T) {
  var M = 0, S = 1;
  for (; T; T = Math.floor(T / 10))
    S = (S + T % 10 * (9 - M++ % 6)) % 11;
  return S ? S - 1 : 'k';
}
