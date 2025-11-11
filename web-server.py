#!/usr/bin/env python3
"""
PiPassive Web Dashboard Server
Server minimalista per la gestione dei servizi via web
"""

import subprocess
import json
import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from datetime import datetime
import socket

class APIHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        """Gestisci richieste GET"""
        if self.path == '/':
            # Verifica se esiste una configurazione valida
            if self.is_configured():
                self.serve_file('web-dashboard.html', 'text/html')
            else:
                # Reindirizza automaticamente alla configurazione
                self.send_response(302)
                self.send_header('Location', '/setup')
                self.end_headers()
                return
        elif self.path == '/setup':
            self.serve_file('setup-dashboard.html', 'text/html')
        elif self.path == '/links':
            self.serve_file('web-links.html', 'text/html')
        elif self.path == '/api/status':
            self.send_json(self.get_status())
        elif self.path == '/api/config':
            self.send_json(self.load_env_config())
        elif self.path.startswith('/api/service/logs/'):
            service = self.path.split('/')[-1]
            self.send_json({'logs': self.get_service_logs(service)})
        else:
            super().do_GET()

    def do_POST(self):
        """Gestisci richieste POST"""
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        
        try:
            data = json.loads(body.decode()) if body else {}
        except:
            data = {}
        
        if self.path == '/api/config':
            success = self.save_env_config(data)
            self.send_json({'success': success, 'message': 'Configurazione salvata con successo' if success else 'Errore nel salvataggio'})
        elif self.path == '/api/test-config':
            result = self.test_config(data)
            self.send_json(result)
        elif self.path == '/api/all/start':
            result = self.run_command('cd /home/pi/PiPassive && ./manage.sh start')
            self.send_json({'success': result[0] == 0, 'message': 'Tutti i servizi avviati'})
        elif self.path == '/api/all/stop':
            result = self.run_command('cd /home/pi/PiPassive && ./manage.sh stop')
            self.send_json({'success': result[0] == 0, 'message': 'Tutti i servizi fermati'})
        elif self.path.startswith('/api/service/start/'):
            service = self.path.split('/')[-1]
            result = self.run_command(f'cd /home/pi/PiPassive && docker compose start {service}')
            self.send_json({'success': result[0] == 0})
        elif self.path.startswith('/api/service/stop/'):
            service = self.path.split('/')[-1]
            result = self.run_command(f'cd /home/pi/PiPassive && docker compose stop {service}')
            self.send_json({'success': result[0] == 0})
        elif self.path.startswith('/api/service/restart/'):
            service = self.path.split('/')[-1]
            result = self.run_command(f'cd /home/pi/PiPassive && docker compose restart {service}')
            self.send_json({'success': result[0] == 0})
        else:
            self.send_error(404)

    def serve_file(self, filename, content_type):
        """Servi un file statico"""
        filepath = Path(filename)
        if filepath.exists():
            self.send_response(200)
            self.send_header('Content-type', content_type)
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            with open(filepath, 'rb') as f:
                self.wfile.write(f.read())
        else:
            self.send_error(404)

    def send_json(self, data):
        """Invia risposta JSON"""
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def get_status(self):
        """Ottieni status di tutti i servizi"""
        status = {
            'system': self.get_system_info(),
            'services': {}
        }

        services = [
            'honeygain', 'pawns', 'packetstream', 'repocket',
            'earnfm', 'mystnode', 'packetshare', 'traffmonetizer'
        ]

        for service in services:
            status['services'][service] = self.get_container_status(service)

        return status

    def get_system_info(self):
        """Ottieni informazioni di sistema"""
        try:
            result = subprocess.run(['hostname', '-I'], capture_output=True, text=True, timeout=5)
            ip = result.stdout.strip().split()[0] if result.stdout.strip() else '192.168.1.100'
        except:
            ip = 'N/A'

        return {
            'ip': ip,
            'timestamp': datetime.now().isoformat()
        }

    def get_container_status(self, container_name):
        """Ottieni status di un container Docker (veloce)"""
        try:
            result = subprocess.run(
                ['docker', 'inspect', '-f', '{{.State.Status}}', container_name],
                capture_output=True,
                text=True,
                timeout=2
            )
            status = result.stdout.strip() if result.returncode == 0 else 'unknown'
        except:
            status = 'unknown'

        # Uptime semplice
        uptime = 'Attivo' if status == 'running' else 'Inattivo'

        return {
            'status': status,
            'cpu': '-',
            'memory': '-',
            'uptime': uptime
        }

    def get_service_logs(self, service_name):
        """Ottieni logs di un servizio"""
        try:
            result = subprocess.run(
                ['docker', 'compose', 'logs', '--tail', '50', service_name],
                capture_output=True,
                text=True,
                timeout=10,
                cwd='/home/pi/PiPassive'
            )
            return result.stdout if result.returncode == 0 else 'Errore nel caricamento dei logs'
        except Exception as e:
            return f'Errore: {str(e)}'

    def run_command(self, command):
        """Esegui un comando shell"""
        try:
            result = subprocess.run(command, shell=True, capture_output=True, timeout=30)
            return (result.returncode, result.stdout.decode(), result.stderr.decode())
        except subprocess.TimeoutExpired:
            return (1, '', 'Timeout')
        except Exception as e:
            return (1, '', str(e))

    def is_configured(self):
        """Verifica se esiste una configurazione valida"""
        env_file = '/home/pi/PiPassive/.env'

        if not Path(env_file).exists():
            return False

        try:
            with open(env_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        key = key.strip()
                        value = value.strip()

                        # Verifica se almeno un servizio ha una configurazione valida
                        if key in ['HONEYGAIN_EMAIL', 'EARNAPP_EMAIL', 'PAWNS_EMAIL', 'PACKETSTREAM_CID', 'TRAFFMONETIZER_TOKEN', 'REPOCKET_EMAIL', 'EARNFM_TOKEN', 'MYSTNODE_API_KEY', 'PACKETSHARE_EMAIL']:
                            if value and value != 'your-email@example.com' and value != 'your-cid-here' and value != 'your-token-here' and value != 'your-api-key-here':
                                return True
            return False
        except:
            return False

    def load_env_config(self):
        """Carica la configurazione dal file .env"""
        config = {}
        env_file = '/home/pi/PiPassive/.env'
        
        if Path(env_file).exists():
            try:
                with open(env_file, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith('#') and '=' in line:
                            key, value = line.split('=', 1)
                            config[key.strip()] = value.strip()
            except Exception as e:
                print(f"Errore nel caricamento .env: {e}")
        
        return config

    def save_env_config(self, config):
        """Salva la configurazione nel file .env"""
        env_file = '/home/pi/PiPassive/.env'
        
        try:
            # Carica la configurazione esistente
            existing = self.load_env_config()
            
            # Aggiorna con i nuovi valori
            existing.update(config)
            
            # Scrivi il nuovo file .env
            with open(env_file, 'w') as f:
                f.write("################################################################################\n")
                f.write("# PiPassive - Environment Configuration\n")
                f.write("# Configurazione automatica via web dashboard\n")
                f.write("################################################################################\n\n")
                
                for key, value in sorted(existing.items()):
                    if value:  # Solo se il valore non è vuoto
                        f.write(f"{key}={value}\n")
            
            return True
        except Exception as e:
            print(f"Errore nel salvataggio .env: {e}")
            return False

    def test_config(self, config):
        """Testa la configurazione con connessioni di base"""
        tests = {
            'honeygain': 'https://www.honeygain.com/',
            'earnapp': 'https://www.earnapp.com/',
            'pawns': 'https://pawns.app/',
            'repocket': 'https://www.repocket.co/',
        }
        
        results = []
        for service, url in tests.items():
            try:
                result = subprocess.run(
                    ['curl', '-sf', '--connect-timeout', '3', url],
                    capture_output=True,
                    timeout=5
                )
                results.append({
                    'service': service,
                    'reachable': result.returncode == 0
                })
            except:
                results.append({
                    'service': service,
                    'reachable': False
                })
        
        return {
            'success': True,
            'message': 'Test completato - Alcuni servizi potrebbero essere irraggiungibili',
            'results': results
        }

    def log_message(self, format, *args):
        """Personalizza i log"""
        sys.stderr.write(f"[{datetime.now().strftime('%H:%M:%S')}] {format % args}\n")


def get_local_ip():
    """Ottieni l'IP locale della Raspberry Pi"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return 'localhost'


def main():
    os.chdir('/home/pi/PiPassive')

    port = 8888
    ip = get_local_ip()
    hostname = 'pipassive.local'

    print("\n" + "="*60)
    print("🍓 PiPassive Web Dashboard")
    print("="*60)
    print(f"\n✓ Server avviato su http://{hostname}:{port}")
    print(f"✓ Indirizzo alternativo: http://{ip}:{port}")
    print(f"\n🌐 Accedi a: http://{hostname}:{port}")
    print(f"\nPremi CTRL+C per fermare il server\n")

    try:
        server = HTTPServer(('0.0.0.0', port), APIHandler)
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n\n✓ Server fermato")
        sys.exit(0)
    except Exception as e:
        print(f"✗ Errore: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()

