package pl.edu.agh.aws.autoscale

import io.gatling.core.Predef._
import io.gatling.http.Predef._

import scala.concurrent.duration._
import scala.language.postfixOps

class DynamicLoadBalancingScenario extends Simulation {

  val httpConf = http
    .baseURL(System.getProperty("elb"))

  val dynamicLoadBalancingScn = scenario("Dynamic load balancing scn")
    .repeat(750) {
      exec(http("GET /random")
        .get("/random"))
    }

  val dynamicLoadBalancingScnCfg = dynamicLoadBalancingScn
    .inject(
      constantUsersPerSec(1) during(180 seconds))
    .protocols(httpConf)

  setUp(
    dynamicLoadBalancingScnCfg
  )

}

