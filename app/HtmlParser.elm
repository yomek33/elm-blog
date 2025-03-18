module HtmlParser exposing (..)
import Html exposing (Html, div, node, text)
import Html.Attributes as Attributes
import Html.Parser as Parser
import Debug


parseHtml : String -> Html msg
parseHtml htmlString =
    case Parser.run htmlString of
        Ok nodes ->
            div [] (nodesToHtml nodes)

        Err errorList ->
            div [] [ text "" ]

{-| nodesToHtml は、パースされた Node のリストを Elm の Html ノードのリストに変換 -}
nodesToHtml : List Parser.Node -> List (Html msg)
nodesToHtml nodes =
    List.map nodeToHtml nodes


{-| nodeToHtml は、1 つの Parser.Node を Elm の Html に再帰的に変換 -}
nodeToHtml : Parser.Node -> Html msg
nodeToHtml node =
    case node of
        Parser.Text content ->
            text content

        Parser.Element tag attrs children ->
            Html.node tag (List.map attributeToHtml attrs) (nodesToHtml children)

        Parser.Comment _ ->
            text ""


{-| attributeToHtml は、(String, String) 型の属性を Elm の Html.Attribute に変換 -}
attributeToHtml : (String, String) -> Html.Attribute msg
attributeToHtml (key, value) =
    Attributes.attribute key value


trimDate : String -> String
trimDate dateTime =
    dateTime
        |> String.split "T"
        |> List.head
        |> Maybe.withDefault ""