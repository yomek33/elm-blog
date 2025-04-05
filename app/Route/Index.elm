module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (div)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import UrlPath
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)
import Microcms
import Html.Attributes exposing (class)
import Component.List

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
        , siteName = "yomek33"
        , image =
            { url =
                [ "images", "icon-png.png" ]
                    |> UrlPath.join
                    |> Pages.Url.fromPath
            , alt = "yomek33 logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to yomek33!"
        , locale = Nothing
        , title = "yomek33 is running"
        }
        |> Seo.website

view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    { title = "yomek33"
    , body =
        [ div [ class "content-container" ]
            [ Component.List.postsContainerView "Archive" app.data.posts
            , Component.List.categoryListComponent app.data.categories
            ]
        ]
    }
