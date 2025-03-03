module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (h1, li, small, text, ul)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import UrlPath
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)
import Microcms
import Html.Attributes 


-- 型定義

type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias ActionData =
    {}


type alias Data =
    { posts : List Microcms.Post
    , categories : List Microcms.Category
    }

fetchData : BackendTask FatalError Data
fetchData =
    Microcms.envTask
        |> BackendTask.andThen
            (\env ->
                BackendTask.map2 Data
                    (Microcms.getPosts env)
                    (Microcms.getCategories env)
            )

-- ルート定義

route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = fetchData
        }
        |> RouteBuilder.buildNoState { view = view }


-- SEO ヘッド設定

head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url =
                [ "images", "icon-png.png" ]
                    |> UrlPath.join
                    |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to elm-pages!"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website

view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    { title = "Blog Posts"
    , body =
        [ Html.div [ Html.Attributes.style "display" "flex" ]
            [ -- メインコンテンツ（記事一覧）
              Html.div [ Html.Attributes.style "flex" "3" ]
                [ h1 [] [ text "ブログ記事一覧" ]
                , ul []
                    (List.map
                        (\post ->
                            li []
                                [ Route.Blog__Slug_ { slug = post.slug }
                                    |> Route.link []
                                        [ Html.div []
                                            [ text post.title
                                            , small [] [ text (" - " ++ post.publishedAt) ]
                                            ]
                                        ]
                                ]
                        )
                        app.data.posts
                    )
                ]

            -- サイドバー
            , Html.div
                [ Html.Attributes.style "flex" "1"
                , Html.Attributes.style "padding-left" "20px"
                , Html.Attributes.style "border-left" "1px solid #ccc"
                ]
                [ h1 [] [ text "カテゴリ一覧" ]
                , ul []
                    (List.map
                        (\category ->
                            li []
                                [ Route.Category__Slug_ { slug = category.slug }
                                    |> Route.link []
                                        [ text category.name ]
                                ]
                        )
                        app.data.categories
                    )
                ]
            ]
        ]
    }