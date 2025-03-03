module Route.Category.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)

import Html exposing (h1, li, text, ul)
import Microcms
import Route
import RouteBuilder exposing (App, StatelessRoute)
import PagesMsg exposing (PagesMsg)
import View exposing (View)
type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }



pages : BackendTask FatalError (List RouteParams)
pages =
    Microcms.envTask
        |> BackendTask.andThen Microcms.getCategories
        |> BackendTask.map (List.map (\category -> { slug = category.slug }))




type alias Data =
    { posts : List Microcms.Post
    , category : String
    }

fetchPosts : RouteParams -> BackendTask FatalError Data
fetchPosts params =
    Microcms.envTask
        |> BackendTask.andThen 
            (\env ->
                BackendTask.map2 Data
                    (Microcms.getPostsByCategory env params.slug)
                    (BackendTask.succeed params.slug)
            )
type alias ActionData =
    {}
route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = fetchPosts
        }
        |> RouteBuilder.buildNoState { view = view }

head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    { title = app.data.category ++ " の記事一覧"
    , body =
        [ h1 [] [ text (app.data.category ++ " の記事一覧") ]
        , ul []
            (List.map
                (\post ->
                    li []
                        [ Route.Blog__Slug_ { slug = post.slug }
                            |> Route.link []
                                [ text post.title ]
                        ]
                )
                app.data.posts
            )
        ]
    }