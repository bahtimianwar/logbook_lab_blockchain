import 'package:flutter/material.dart';

class Alat {
  final String nama;
  final String kategori;
  final IconData ikon;
  const Alat(this.nama, this.kategori, this.ikon);
}

const kategoriAlat = [
  'Mikrokontroler',
  'Sensor',
  'Aktuator & Display',
  'Komunikasi',
  'Alat Ukur',
  'Aksesori',
];

// PENTING: kontrak membedakan huruf besar dan kecil, dan satu nama hanya bisa
// dipinjam satu orang pada satu waktu. Kalau di lab ada beberapa unit alat yang
// sama, beri nama berbeda per unit, misalnya "Arduino UNO (Unit 2)".
// Sesuaikan daftar ini dengan alat Lab IoT yang sebenarnya.
const List<Alat> daftarAlat = [
  // Mikrokontroler
  Alat('Arduino UNO', 'Mikrokontroler', Icons.developer_board),
  Alat('Arduino UNO (Unit 2)', 'Mikrokontroler', Icons.developer_board),
  Alat('Arduino Nano', 'Mikrokontroler', Icons.memory),
  Alat('ESP32 DevKit', 'Mikrokontroler', Icons.memory),
  Alat('ESP8266 NodeMCU', 'Mikrokontroler', Icons.memory),
  Alat('Raspberry Pi 4', 'Mikrokontroler', Icons.developer_board),
  // Sensor
  Alat('Sensor DHT11', 'Sensor', Icons.thermostat),
  Alat('Sensor DHT22', 'Sensor', Icons.thermostat),
  Alat('Sensor Ultrasonik HC-SR04', 'Sensor', Icons.sensors),
  Alat('Sensor LDR', 'Sensor', Icons.light_mode),
  Alat('Sensor Gas MQ-2', 'Sensor', Icons.cloud),
  Alat('Sensor Soil Moisture', 'Sensor', Icons.water_drop),
  // Aktuator dan display
  Alat('Servo SG90', 'Aktuator & Display', Icons.settings),
  Alat(
    'Motor DC + Driver L298N',
    'Aktuator & Display',
    Icons.precision_manufacturing,
  ),
  Alat(
    'Modul Relay 4 Channel',
    'Aktuator & Display',
    Icons.electrical_services,
  ),
  Alat('Buzzer', 'Aktuator & Display', Icons.volume_up),
  Alat('LCD 16x2 I2C', 'Aktuator & Display', Icons.monitor),
  // Komunikasi
  Alat('Modul Bluetooth HC-05', 'Komunikasi', Icons.bluetooth),
  Alat('Modul LoRa SX1278', 'Komunikasi', Icons.cell_tower),
  Alat('Modul RFID RC522', 'Komunikasi', Icons.nfc),
  // Alat ukur
  Alat('Multimeter Digital', 'Alat Ukur', Icons.speed),
  Alat('Power Supply DC', 'Alat Ukur', Icons.bolt),
  // Aksesori
  Alat('Breadboard', 'Aksesori', Icons.grid_on),
  Alat('Kabel Jumper Set', 'Aksesori', Icons.cable),
  Alat('Solder + Timah', 'Aksesori', Icons.build),
];

IconData ikonUntuk(String nama) {
  for (final a in daftarAlat) {
    if (a.nama == nama) return a.ikon;
  }
  return Icons.build;
}
