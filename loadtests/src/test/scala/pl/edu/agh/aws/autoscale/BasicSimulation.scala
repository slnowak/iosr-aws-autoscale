package pl.edu.agh.aws.autoscale

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._


class BasicSimulation extends Simulation {

  val httpConf = http.baseURL("http://computer-database.gatling.io")

  val scn = scenario("BasicSimulation")
    .exec(
      http("request_1").get("/")
    )

  setUp(
    scn.inject(constantUsersPerSec(10).during(1 minute))
  ).protocols(httpConf)

}
