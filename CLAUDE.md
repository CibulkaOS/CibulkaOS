#CibulkaOS

Distribuce Arch Linuxu na motivy Petra Cibulky - bizardního českého Politika.

## Build systém
Používá se archiso dokumentováno na arch wiki: https://wiki.archlinux.org/title/Archiso

## Speciální funkcionalita systému:
- Grafický instalator

- Anti-GRU(B) Bootloader: Tradiční zavaděč GRUB by musel být přejmenován na Anti-GRUB (aby neasocioval ruskou vojenskou rozvědku GRU). Při startu systému by probíhala kontrola, zda do bootovací sekvence nezasáhli ruští agenti.

- Siderický generátor náhodných čísel: Místo klasického /dev/urandom by systém disponoval modulem /dev/kyvadlo. Šifrovací klíče a náhodná čísla by se generovala výhradně na základě virtuálního siderického informačního kyvadla, které je v přímém kontaktu s vyššími sférami.

- Příkaz sudo nahrazen kyvadlo: Systém pak s 50% pravděpodobností odpoví, že jste infiltrovaný agent STB a přístup zamítne.

- Lustrace uživatelů: Root uživatel se jmenuje cibulka. Přidání nového uživatele (příkaz adduser) by automaticky prohnalo jméno nového profilu "Cibulkovými seznamy". Pokud by došlo ke shodě, účet by byl rovnou smazan.

- Firewall proti fízlokracii: Vestavěný firewall by automaticky blokoval všechny IP adresy pocházející z Ruska a Číny. Veškeré systémové chyby (např. error 404) by systém nehlásil jako chybu sítě, ale jako "Úspěšnou sabotáž marxisticko-leninských struktur".
