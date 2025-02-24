import socket
import ssl
import datetime
import sys

import OpenSSL
domains_url = sys.argv[1:]



def ssl_expiry_datetime(hostname):
    ssl_dateformat = r'%b %d %H:%M:%S %Y %Z'


    context = ssl.create_default_context()
    context.verify_mode = ssl.CERT_REQUIRED
    context.check_hostname = False


    conn = context.wrap_socket(
        socket.socket(socket.AF_INET),
        server_hostname=hostname,
    )
    # 5 second timeout
    conn.settimeout(5.0)

    conn.connect((hostname, 443))
    ssl_info = conn.getpeercert()
    # Python datetime object
    return datetime.datetime.strptime(ssl_info['notAfter'], ssl_dateformat)

def get_num_days_before_expired(hostname: str, port: str = '443') -> int:
    """
    Get number of days before an TLS/SSL of a domain expired
    """

    context = ssl.SSLContext()
    with socket.create_connection((hostname, port)) as sock:
        with context.wrap_socket(sock, server_hostname = hostname) as ssock:
            certificate = ssock.getpeercert(True)
            cert = ssl.DER_cert_to_PEM_cert(certificate)
            x509 = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, cert)
            cert_expires = datetime.datetime.strptime(x509.get_notAfter().decode('utf-8'), '%Y%m%d%H%M%S%fz')
            return cert_expires

if __name__ == "__main__":
    for value in domains_url:
        now = datetime.datetime.now()
        try:
            expire = get_num_days_before_expired(value)

            diff = expire - now
            if (diff.days<1):
                print ("Certificado Expirado!  "+str(diff.days)+" dias para expirar o certificado")
                sys.exit(2)
            if (diff.days<5):
                print ("Faltam "+str(diff.days)+" dias para expirar o certificado")
                sys.exit(1)
            if (diff.days>5):
                print ("Dominio: {} dias restantes: {}".format(value,diff.days))
                sys.exit(0)
        except Exception as e:
            print (e)

                     
