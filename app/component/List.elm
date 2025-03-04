module Component.List exposing (postsContainerView, categoryListComponent, categoryItemView)
import Microcms
import Html exposing (h1,h3,h2, li, small, text, ul, div, span)
import Html.Attributes exposing (class, style)
import Route
import PagesMsg exposing (PagesMsg)
import Util

type alias Msg =
    ()

postsContainerView : String -> List Microcms.Post -> Html.Html (PagesMsg Msg)
postsContainerView header posts =
    div [ class "post-container" ]
        [ div [ style "flex" "3" ]
            [ h1 [] [ text header ]
            , div [ class "post-list" ]
                [ ul [] (List.map postItemView posts) ]
            ]
        ]


postItemView : Microcms.Post -> Html.Html (PagesMsg Msg)
postItemView post =
    li []
        [ Route.Blog__Slug_ { slug = post.slug }
            |> Route.link []
                [ div []
                    [ h2 [class "post-list-title"]
                        [text post.title]
                    , small [] 
                        [ text (Util.trimDate post.publishedAt)
                        , span [ class "post-category-name" ] 
                             [ text (Maybe.withDefault "" (List.head post.categories |> Maybe.map (.name >> (++) "#"))) ]
                        ]
                    ]
                ]
        ]


categoryListComponent : List Microcms.Category -> Html.Html (PagesMsg Msg)
categoryListComponent categories =
    div [ class "category-container" ]
        [ h3 [] [ text "Category" ]
        , div [ class "category-list" ]
            [ ul [] (List.map categoryItemView categories) ]
        ]


categoryItemView : Microcms.Category -> Html.Html (PagesMsg Msg)
categoryItemView category =
    li []
        [ Route.Category__Slug_ { slug = category.slug }
            |> Route.link []
                [ text ("#" ++ category.name) ]
        ]
