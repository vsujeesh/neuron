{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Neuron.Web.Zettel.CSS
  ( zettelCss,
  )
where

import Clay hiding (id, ms, not, object, reverse, s, style, type_)
import qualified Clay as C
import qualified Neuron.Web.Theme as Theme
import Relude hiding ((&))

lightColor :: Theme.Theme -> Color
lightColor neuronTheme =
  Theme.withRgb neuronTheme C.rgba 0.1

themeColor :: Theme.Theme -> Color
themeColor neuronTheme =
  Theme.withRgb neuronTheme C.rgba 1

zettelCss :: Theme.Theme -> Css
zettelCss neuronTheme = do
  zettelCommonCss neuronTheme
  zettelLinkCss neuronTheme
  "div.zettel-view" ? do
    -- This list styling applies both to zettel content, and the rest of the
    -- view (eg: connections pane)
    C.ul ? do
      C.paddingLeft $ em 1.5
      C.listStyleType C.square
      C.li ? do
        mempty -- C.paddingBottom $ em 1
    zettelContentCss neuronTheme
  pureCssTreeDiagram
  ".ui.label.zettel-tag a.tag-inner" ? do
    C.color black
    "a" ? do
      C.color black

zettelLinkCss :: Theme.Theme -> Css
zettelLinkCss neuronTheme = do
  let linkColor = Theme.withRgb neuronTheme C.rgb
  "span.zettel-link-container span.zettel-link a" ? do
    C.fontWeight C.bold
    C.color linkColor
    C.textDecoration C.none
  "span.zettel-link-container span.zettel-link a:hover" ? do
    C.backgroundColor linkColor
    C.color C.white
  "span.zettel-link-container span.extra" ? do
    C.color C.auto
    C.paddingRight $ em 0.3
  "span.zettel-link-container.folgezettel::after" ? do
    C.paddingLeft $ em 0.3
    C.content $ C.stringContent "ᛦ"
  "[data-tooltip]:after" ? do
    C.fontSize $ em 0.7

zettelContentCss :: Theme.Theme -> Css
zettelContentCss neuronTheme = do
  let linkColor = Theme.withRgb neuronTheme C.rgb
  ".zettel-content" ? do
    -- All of these apply to the zettel content card only.
    "div.date" ? do
      C.textAlign C.center
      C.color C.gray
    C.h1 ? do
      C.paddingTop $ em 0.2
      C.paddingBottom $ em 0.2
      C.textAlign C.center
      C.backgroundColor $ lightColor neuronTheme
    C.h2 ? do
      C.borderBottom C.solid (px 1) C.steelblue
      C.marginBottom $ em 0.5
    C.h3 ? do
      C.margin (px 0) (px 0) (em 0.4) (px 0)
    C.h4 ? do
      C.opacity 0.8
    "div#footnotes" ? do
      C.marginTop $ em 4
      C.borderTop C.groove (px 2) linkColor
      C.fontSize $ em 0.9
    -- reflex-dom-pandoc footnote aside elements
    -- (only used for footnotes defined inside footnotes)
    "aside.footnote-inline" ? do
      C.width $ pct 30
      C.paddingLeft $ px 15
      C.marginLeft $ px 15
      C.float C.floatRight
      C.backgroundColor C.lightgray
    -- CSS library for users to use in their Pandoc attributes blocks
    ".overflows" ? do
      C.overflow auto
    -- End of div.zettel-content
    codeStyle
    definitionListStyle
    blockquoteStyle
  where
    definitionListStyle = do
      C.dl ? do
        C.dt ? do
          C.fontWeight C.bold
        C.dd ? do
          mempty
    codeStyle = do
      C.code ? do
        sym C.margin auto
        C.fontSize $ pct 100
      -- This pretty much selects inline code elements
      "p code, li code, ol code" ? do
        sym C.padding $ em 0.2
        C.backgroundColor "#f8f8f8"
      -- This selects block code elements
      pre ? do
        sym C.padding $ em 0.5
        C.overflow auto
        C.maxWidth $ pct 100
      "div.pandoc-code" ? do
        C.marginLeft auto
        C.marginRight auto
        pre ? do
          C.backgroundColor "#f8f8f8"
    -- https://css-tricks.com/snippets/css/simple-and-nice-blockquote-styling/
    blockquoteStyle =
      C.blockquote ? do
        C.backgroundColor "#f9f9f9"
        C.borderLeft C.solid (px 10) "#ccc"
        sym2 C.margin (em 1.5) (px 0)
        sym2 C.padding (em 0.5) (px 10)

zettelCommonCss :: Theme.Theme -> Css
zettelCommonCss neuronTheme = do
  "p" ? do
    C.lineHeight $ pct 150
  "img" ? do
    C.maxWidth $ pct 100 -- Prevents large images from overflowing beyond zettel borders
  ".deemphasized" ? do
    fontSize $ em 0.85
  ".deemphasized:hover" ? do
    opacity 1
    "div.item a:hover" ? important (color $ themeColor neuronTheme)
  ".deemphasized:not(:hover)" ? do
    opacity 0.7
    "span.zettel-link a, div.item a" ? important (color gray)

-- https://codepen.io/philippkuehn/pen/QbrOaN
pureCssTreeDiagram :: Css
pureCssTreeDiagram = do
  let cellBorderWidth = px 2
      flipTree = False
      rotateDeg = deg 180
  ".tree.flipped" ? do
    C.transform $ C.rotate rotateDeg
  ".tree" ? do
    C.overflow auto
    when flipTree $ do
      C.transform $ C.rotate rotateDeg
    -- Clay does not support this; doing it inline in div style.
    -- C.transformOrigin $ pct 50
    "ul.root" ? do
      -- Make the tree attach to zettel segment
      C.paddingTop $ px 0
      C.marginTop $ px 0
    "ul" ? do
      C.position relative
      C.padding (em 1) 0 0 0
      C.whiteSpace nowrap
      sym2 C.margin (px 0) auto
      C.textAlign center
      C.after & do
        C.content $ stringContent ""
        C.display C.displayTable
        C.clear both
      C.lastChild & do
        C.paddingBottom $ em 0.1
    "li" ? do
      C.display C.inlineBlock
      C.verticalAlign C.vAlignTop
      C.textAlign C.center
      C.listStyleType none
      C.position relative
      C.padding (em 1) (em 0.5) (em 0) (em 0.5)
      forM_ [C.before, C.after] $ \sel -> sel & do
        C.content $ stringContent ""
        C.position absolute
        C.top $ px 0
        C.right $ pct 50
        C.borderTop solid cellBorderWidth "#ccc"
        C.width $ pct 50
        C.height $ em 1.2
      C.after & do
        C.right auto
        C.left $ pct 50
        C.borderLeft solid cellBorderWidth "#ccc"
      C.onlyChild & do
        C.paddingTop $ em 0
        forM_ [C.after, C.before] $ \sel -> sel & do
          C.display none
      C.firstChild & do
        C.before & do
          C.borderStyle none
          C.borderWidth $ px 0
        C.after & do
          C.borderRadius (px 5) 0 0 0
      C.lastChild & do
        C.after & do
          C.borderStyle none
          C.borderWidth $ px 0
        C.before & do
          C.borderRight solid cellBorderWidth "#ccc"
          C.borderRadius 0 (px 5) 0 0
    "ul ul::before" ? do
      C.content $ stringContent ""
      C.position absolute
      C.top $ px 0
      C.left $ pct 50
      C.borderLeft solid cellBorderWidth "#ccc"
      C.width $ px 0
      C.height $ em 1.2
    "li" ? do
      "div.forest-link" ? do
        border solid cellBorderWidth "#ccc"
        sym2 C.padding (em 0.2) (em 0.3)
        C.textDecoration none
        C.display inlineBlock
        sym C.borderRadius (px 5)
        C.color "#333"
        C.position relative
        C.top cellBorderWidth
        when flipTree $ do
          C.transform $ C.rotate rotateDeg
  ".tree.flipped li div.forest-link" ? do
    C.transform $ C.rotate rotateDeg
