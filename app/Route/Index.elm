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
import Microcms


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
    { posts : List Microcms.Post }


data : BackendTask FatalError Data
data =
    Microcms.envTask
        |> BackendTask.andThen Microcms.getPosts
        |> BackendTask.map (\posts -> { posts = posts })
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
                                    , Html.small [] [ Html.text (" - " ++ post.publishedAt) ]
                                    ]
                                ]
                        ]
                )
                app.data.posts
            )
        ]
    }