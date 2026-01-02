import qs.component.common

Pill {
  RepeatedCommand {
    command: ["curl", "-s", "ftp://ftp.bom.gov.au/anon/gen/fwo/IDV10753.xml"]
    onFinished: output => {
      console.log(output)
    }
  }
}
