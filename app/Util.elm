module Util exposing (trimDate)

trimDate : String -> String
trimDate dateTime =
    dateTime
        |> String.split "T"
        |> List.head
        |> Maybe.withDefault ""