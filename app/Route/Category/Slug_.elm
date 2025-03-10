module Route.Category.Slug_ exposing (ActionData, Data, Model, Msg, route)
import RouteBuilder exposing (StatelessRoute)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)
import Html exposing ( div)
import Html.Attributes exposing (class)
import Microcms
import RouteBuilder exposing (App, StatelessRoute)
import PagesMsg exposing (PagesMsg)
import View exposing (View)
import Component.List
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
    , categories : List Microcms.Category
    , currentCategory : String
    }

fetchData :  RouteParams -> BackendTask FatalError Data
fetchData params =
    Microcms.envTask
        |> BackendTask.andThen 
            (\env ->
                BackendTask.map3 Data
                    (Microcms.getPostsByCategory env params.slug)
                    (Microcms.getCategories env)
                    (BackendTask.succeed params.slug)
            )
type alias ActionData =
    {}
route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = fetchData
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
    { title = "\"" ++ app.data.currentCategory ++ "\""
    , body =
        [ div [ class "content-container" ]
              [ Component.List.postsContainerView ("\"" ++ app.data.currentCategory ++ "\"") app.data.posts
            , Component.List.categoryListComponent app.data.categories
            ]
        ]
    }
