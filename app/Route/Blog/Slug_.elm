module Route.Blog.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (div, h1, text)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)
import Microcms

import Server.Request
import Server.Response
import ErrorPage
import HtmlParser


-- MODEL & MESSAGE

type alias Model =
    {}

type alias Msg =
    ()


type alias RouteParams =
    { slug : String }

type alias Data =
    { post : Microcms.Post }

type alias ActionData =
    {}


fetchPost : RouteParams -> BackendTask FatalError Microcms.Post
fetchPost params =
    Microcms.envTask
        |> BackendTask.andThen (\env -> Microcms.getPost env params.slug)


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    fetchPost routeParams
        |> BackendTask.map (\post -> { post = post })



route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.serverRender
        { head = head
        , data = \routeParams _ ->
            fetchPost routeParams
                |> BackendTask.map (\post -> { post = post })
                |> BackendTask.map Server.Response.render
        , action = \_ _ ->
            BackendTask.succeed (Server.Response.render {})
        }
        |> RouteBuilder.buildNoState { view = view }



head : App Data ActionData RouteParams -> List Head.Tag
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
        , title = app.data.post.title
        }
        |> Seo.website

view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    { title = app.data.post.title
    , body =
        [ div []
            [ h1 [] [ text app.data.post.title ]
            , case app.data.post.content of
                Just content ->
                   HtmlParser.parseHtml content
                Nothing ->
                    text ""
            ]
        ]
    }