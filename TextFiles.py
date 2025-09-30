import PyPDF2

with open('sb_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('sb_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to sb_records.txt")

with open('bsb_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('bsb_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to bsb_records.text")

with open('Cross_Country_Records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('Cross_Country_Records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to Cross_Country_Records.txt")

with open ('fball_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('fball_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to fball_records.txt")

with open('mbb_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open ('mbb_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to mbb_records.txt")

with open('mens_tennis_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('mens_tennis_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to mens_tennis_records.txt")

with open('mhoc_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('mhoc_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to mhoc_records.txt")

with open('msoc_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('msoc_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to msoc_records.txt")

with open('vball_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('vball_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to vball_records.txt")

with open('wbb_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('wbb_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to wbb_records.txt")

with open('whoc_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('whoc_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to whoc_records.txt")

with open('wsoc_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('wsoc_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to wsoc_records.txt")

with open('wtennis_records.pdf', 'rb') as pdf_file:
    reader = PyPDF2.PdfReader(pdf_file)
    text = ""

    for page in reader.pages:
        text += page.extract_text() + "\n"

        with open('wtennis_records.txt', 'w', encoding='utf-8') as text_file:
            text_file.write(text)
            print("PDF content has been successfully extracted to wtennis_records.txt")