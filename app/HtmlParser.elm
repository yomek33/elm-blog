module HtmlParser exposing (..)
import Html exposing (Html, div, node, text)
import Html.Attributes as Attributes
import Html.Parser as Parser

parseHtml : String -> Html msg
parseHtml htmlString =
    case Parser.run htmlString of
        Ok nodes ->
            div [] (nodesToHtml nodes)

        Err errorList ->
            div [] [ text "" ]

{-| パースされたNodeのリストをElmのHtmlノードのリストに変換 -}
nodesToHtml : List Parser.Node -> List (Html msg)
nodesToHtml nodes =
    List.map nodeToHtml nodes


{-| Parser.NodeをElmのHtmlに再帰的に変換 -}
nodeToHtml : Parser.Node -> Html msg
nodeToHtml node =
    case node of
        Parser.Text content ->
            text content

        Parser.Element tag attrs children ->
            Html.node tag (List.map attributeToHtml attrs) (nodesToHtml children)

        Parser.Comment _ ->
            text ""


{-| (String, String)をElmのHtml.Attribute に変換 -}
attributeToHtml : (String, String) -> Html.Attribute msg
attributeToHtml (key, value) =
    Attributes.attribute key value


trimDate : String -> String
trimDate dateTime =
    dateTime
        |> String.split "T"
        |> List.head
        |> Maybe.withDefault ""