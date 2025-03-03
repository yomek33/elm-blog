module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Pages.Url
import PagesMsg exposing (PagesMsg)
import UrlPath
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}



type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }
type alias Data =
    { posts : List Post }

type alias Post =
    { slug : String
    , title : String
    , date : String
    }
data : BackendTask FatalError Data
data =
    BackendTask.succeed Data
        |> BackendTask.andMap
            (BackendTask.succeed
                [ { slug = "first-post"
                  , title = "はじめての投稿"
                  , date = "2024-03-20"
                  }
                , { slug = "second-post"
                  , title = "2番目の投稿"
                  , date = "2024-03-21"
                  }
                , { slug = "third-post"
                  , title = "3番目の投稿"
                  , date = "2024-03-22"
                  }
                ]
            )


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to elm-pages!"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "Blog Posts"
    , body =
        [ Html.h1 [] [ Html.text "ブログ記事一覧" ]
        , Html.ul []
            (List.map
                (\post ->
                    Html.li []
                        [ Route.Blog__Slug_ { slug = post.slug }
                            |> Route.link []
                                [ Html.div []
                                    [ Html.text post.title
                                    , Html.small [] [ Html.text (" - " ++ post.date) ]
                                    ]
                                ]
                        ]
                )
                app.data.posts
            )
        ]
    }