import PyPDF2

def pdf_to_text(pdf_filename, text_filename):
    with open(pdf_filename, 'rb') as pdf_file:
        reader = PyPDF2.PdfReader(pdf_file)
        text = ""

        for page in reader.pages:
            text += page.extract_text() + "/n"
        with open(text_filename, 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print(f"PDF content has been successfully extracted to {text_filename}")

files = [
    ('sb_records.pdf', 'sb_records.txt'),
    ('bsb_records.pdf', 'bsb_records.txt'),
    ('Cross_Country_Records.pdf', 'Cross_Country_Records.txt'),
    ('fball_records.pdf', 'fball_records.txt'),
    ('mbb_records.pdf', 'mbb_records.txt'),
    ('mens_tennis_records.pdf', 'mens_tennis_records.txt'),
    ('mhoc_records.pdf', 'mhoc_records.txt'),
    ('msoc_records.pdf', 'msoc_records.txt'),
    ('vball_records.pdf', 'vball_records.txt'),
    ('wbb_records.pdf', 'wbb_records.txt'),
    ('whoc_records.pdf', 'whoc_records.txt'),
    ('wsoc_records.pdf', 'wsoc_records.txt'),
    ('wtennis_records.pdf', 'wtennis_records.txt')
]

for pdf_file, text_file in files:
    pdf_to_text(pdf_file, text_file)

