# asciidoctor-texnical

Typeset equations with latex in your asciidoc-documents. It is an alternative to
[asciidoctor-mathematical][asciidoctor-mathematical].

In contrast to [asciidoctor-mathematical][asciidoctor-mathematical],
asciidoctor-texnical does not rely on third-party libraries but directly shells
out to latex. This means it can work in environments, where the
[mathematical][mathematical] library cannot be installed (my primary motivation
for writing this gem).

People who want to process untrusted asciidoc documents might rather use
[asciidoctor-mathematical][asciidoctor-mathematical], because this gem does not
do any kind of input validation.

[asciidoctor-mathematical]: https://github.com/asciidoctor/asciidoctor-mathematical
[mathematical]: https://github.com/gjtorikian/mathematical
