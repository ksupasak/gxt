import ssl
import sys
ssl._create_default_https_context = ssl._create_unverified_context


from weasyprint import HTML
#HTML('https://localhost:1792/wu/Admit/partial?id=63b4e43a95d90df7699004d2').write_pdf('weasyprint.pdf')

HTML(sys.argv[1]).write_pdf(sys.argv[2])
