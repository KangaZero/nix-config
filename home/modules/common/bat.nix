{ pkgs, ... }:
let
  c = import ./theme.nix;
in
{
  programs.bat = {
    enable = true;
    config = {
      theme = "tokyonight-kanga";
      style = "numbers,changes,header";
    };
    extraPackages = with pkgs.bat-extras; [
      batdiff # git diff through bat
      batman # man pages through bat
      batgrep # ripgrep output through bat
    ];
    # tokyonight-kanga — Tokyo Night Moon body + Dracula-purple accent
    #
    # `themes.<name>` as a bare string is deprecated; the live type is a
    # submodule taking `src` (path) plus optional `file` (subpath within it).
    # Upstream expects a fetched theme repo, so a single generated .tmTheme goes
    # through writeText — `file` stays null because src already is the file.
    themes.tokyonight-kanga.src = pkgs.writeText "tokyonight-kanga.tmTheme" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>name</key>
        <string>Tokyo Night Kanga</string>
        <key>settings</key>
        <array>
          <!-- Global -->
          <dict>
            <key>settings</key>
            <dict>
              <key>background</key>             <string>${c.bg}</string>
              <key>foreground</key>             <string>${c.fg}</string>
              <key>caret</key>                 <string>${c.fg}</string>
              <key>gutter</key>                <string>${c.bg}</string>
              <key>gutterForeground</key>      <string>${c.comment}</string>
              <key>invisibles</key>            <string>${c.bgDark}</string>
              <key>lineHighlight</key>         <string>${c.bgHighlight}</string>
              <key>selection</key>             <string>${c.bgHighlight}</string>
              <key>selectionBorder</key>       <string>${c.border}</string>
              <key>findHighlight</key>         <string>${c.yellow}</string>
              <key>findHighlightForeground</key><string>${c.bg}</string>
            </dict>
          </dict>
          <!-- Comment -->
          <dict>
            <key>name</key><string>Comment</string>
            <key>scope</key><string>comment, punctuation.definition.comment</string>
            <key>settings</key>
            <dict>
              <key>foreground</key><string>${c.comment}</string>
              <key>fontStyle</key><string>italic</string>
            </dict>
          </dict>
          <!-- String -->
          <dict>
            <key>name</key><string>String</string>
            <key>scope</key><string>string, string.quoted, string.template</string>
            <key>settings</key><dict><key>foreground</key><string>${c.green}</string></dict>
          </dict>
          <!-- String escape / regexp -->
          <dict>
            <key>name</key><string>String Escape</string>
            <key>scope</key><string>constant.character.escape, string.regexp</string>
            <key>settings</key><dict><key>foreground</key><string>${c.cyan}</string></dict>
          </dict>
          <!-- Number / boolean / constant -->
          <dict>
            <key>name</key><string>Number</string>
            <key>scope</key><string>constant.numeric</string>
            <key>settings</key><dict><key>foreground</key><string>${c.orange}</string></dict>
          </dict>
          <dict>
            <key>name</key><string>Constant</string>
            <key>scope</key><string>constant, constant.language, constant.language.boolean</string>
            <key>settings</key><dict><key>foreground</key><string>${c.orange}</string></dict>
          </dict>
          <!-- Keyword / storage — Dracula purple accent -->
          <dict>
            <key>name</key><string>Keyword</string>
            <key>scope</key><string>keyword, keyword.control, storage.type, storage.modifier</string>
            <key>settings</key>
            <dict>
              <key>foreground</key><string>${c.purple}</string>
              <key>fontStyle</key><string>bold</string>
            </dict>
          </dict>
          <!-- Function — blue -->
          <dict>
            <key>name</key><string>Function</string>
            <key>scope</key><string>entity.name.function, meta.function-call.generic</string>
            <key>settings</key><dict><key>foreground</key><string>${c.blue}</string></dict>
          </dict>
          <!-- Support function (built-ins) — cyan -->
          <dict>
            <key>name</key><string>Support Function</string>
            <key>scope</key><string>support.function</string>
            <key>settings</key><dict><key>foreground</key><string>${c.cyan}</string></dict>
          </dict>
          <!-- Type / class — teal -->
          <dict>
            <key>name</key><string>Type</string>
            <key>scope</key>
            <string>entity.name.type, entity.name.class, entity.name.struct,
                    entity.name.enum, entity.name.interface,
                    support.type, support.class</string>
            <key>settings</key><dict><key>foreground</key><string>${c.teal}</string></dict>
          </dict>
          <!-- HTML/JSX tag — red -->
          <dict>
            <key>name</key><string>Tag Name</string>
            <key>scope</key><string>entity.name.tag</string>
            <key>settings</key><dict><key>foreground</key><string>${c.red}</string></dict>
          </dict>
          <!-- HTML/JSX attribute — orange -->
          <dict>
            <key>name</key><string>Tag Attribute</string>
            <key>scope</key><string>entity.other.attribute-name</string>
            <key>settings</key><dict><key>foreground</key><string>${c.orange}</string></dict>
          </dict>
          <!-- Variable -->
          <dict>
            <key>name</key><string>Variable</string>
            <key>scope</key><string>variable, variable.other</string>
            <key>settings</key><dict><key>foreground</key><string>${c.fg}</string></dict>
          </dict>
          <!-- Property — blue -->
          <dict>
            <key>name</key><string>Property</string>
            <key>scope</key>
            <string>variable.other.member, variable.other.object.property,
                    support.variable.property</string>
            <key>settings</key><dict><key>foreground</key><string>${c.blue}</string></dict>
          </dict>
          <!-- Operator -->
          <dict>
            <key>name</key><string>Operator</string>
            <key>scope</key><string>keyword.operator</string>
            <key>settings</key><dict><key>foreground</key><string>${c.operator}</string></dict>
          </dict>
          <!-- Punctuation -->
          <dict>
            <key>name</key><string>Punctuation</string>
            <key>scope</key>
            <string>punctuation.definition, punctuation.separator, punctuation.terminator</string>
            <key>settings</key><dict><key>foreground</key><string>${c.fgDark}</string></dict>
          </dict>
          <!-- Decorator / annotation — magenta -->
          <dict>
            <key>name</key><string>Decorator</string>
            <key>scope</key>
            <string>entity.name.decorator, entity.name.function.decorator,
                    punctuation.definition.annotation, meta.decorator</string>
            <key>settings</key><dict><key>foreground</key><string>${c.magenta}</string></dict>
          </dict>
          <!-- Import / namespace — purple accent -->
          <dict>
            <key>name</key><string>Import</string>
            <key>scope</key>
            <string>entity.name.namespace, entity.name.module,
                    keyword.control.import, keyword.control.from</string>
            <key>settings</key><dict><key>foreground</key><string>${c.purple}</string></dict>
          </dict>
          <!-- Invalid -->
          <dict>
            <key>name</key><string>Invalid</string>
            <key>scope</key><string>invalid, invalid.illegal</string>
            <key>settings</key><dict><key>foreground</key><string>${c.invalid}</string></dict>
          </dict>
        </array>
        <key>uuid</key>
        <string>tokyonight-kanga-bat</string>
      </dict>
      </plist>
    '';
  };
}
