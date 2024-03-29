String getDeviceStatusCode(String status) {
  switch (status) {
    case 'Desconfigurado':
      {
        return '0';
      }
    case 'Bloqueado':
      {
        return '1';
      }
    case 'Desbloqueado':
      {
        return '2';
      }
    case 'Disparado':
      {
        return '3';
      }
    case 'Aguardando confirmação':
      {
        return '4';
      }
    default:
      {
        return '0';
      }
  }
}

String getDeviceStatusLabel(String status) {
  switch (status) {
    case '0':
      {
        return 'Desconfigurado';
      }
    case '1':
      {
        return 'Bloqueado';
      }
    case '2':
      {
        return 'Desbloqueado';
      }
    case '3':
      {
        return 'Disparado';
      }
    case '4':
      {
        return 'Aguardando confirmação';
      }
    default:
      {
        return 'Desconfigurado';
      }
  }
}
