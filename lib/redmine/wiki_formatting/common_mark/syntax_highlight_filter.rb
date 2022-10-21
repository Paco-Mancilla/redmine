# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2022  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Redmine
  module WikiFormatting
    module CommonMark
      # Redmine Syntax highlighting for <pre><code class="language-foo">
      # blocks as generated by commonmarker
      class SyntaxHighlightFilter < HTML::Pipeline::Filter
        def call
          doc.search("pre > code").each do |node|
            next unless lang = node["class"].presence
            next unless lang =~ /\Alanguage-(\S+)\z/

            lang = $1
            text = node.inner_text

            # original language for extension development
            node["data-language"] = lang unless node["data-language"]

            if Redmine::SyntaxHighlighting.language_supported?(lang)
              html = Redmine::SyntaxHighlighting.highlight_by_language(text, lang)
              next if html.nil?

              node.inner_html = html
              node["class"] = "#{lang} syntaxhl"
            else
              # unsupported language, remove the class attribute
              node.remove_attribute("class")
            end
          end
          doc
        end
      end
    end
  end
end
