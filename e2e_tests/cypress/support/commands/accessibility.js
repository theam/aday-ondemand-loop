import 'cypress-axe'

const getDefaultAxeConfig = () => {
  const envConfig = Cypress.env('axe') || {}

  const defaults = {
    context: envConfig.context ?? 'body',
    skipFailures: envConfig.skipFailures ?? false,
    options: {},
  }

  const runOnly = envConfig.runOnly ?? null
  if (runOnly) {
    defaults.options.runOnly = runOnly
  }

  const includedImpacts = envConfig.includedImpacts ?? null
  if (includedImpacts) {
    defaults.options.includedImpacts = includedImpacts
  }

  if (envConfig.rules) {
    defaults.options.rules = envConfig.rules
  }

  return defaults
}

const mergeAxeOptions = (base = {}, overrides = {}) => {
  const merged = { ...base, ...overrides }

  if (base.rules || overrides.rules) {
    merged.rules = {
      ...(base.rules || {}),
      ...(overrides.rules || {}),
    }
  }

  if (Object.prototype.hasOwnProperty.call(overrides, 'runOnly')) {
    if (overrides.runOnly === null) {
      delete merged.runOnly
    } else {
      merged.runOnly = overrides.runOnly
    }
  }

  if (Object.prototype.hasOwnProperty.call(overrides, 'includedImpacts')) {
    if (overrides.includedImpacts === null) {
      delete merged.includedImpacts
    } else {
      merged.includedImpacts = overrides.includedImpacts
    }
  }

  return merged
}

const summarizeViolations = (violations) =>
  violations.map(({ id, impact, description, nodes }) => ({
    id,
    impact,
    description,
    nodes: nodes.length,
    targets: nodes.flatMap((node) => node.target),
  }))

const logViolationsToNode = (violations) => {
  const summary = summarizeViolations(violations)

  cy.task('logAxeViolations', {
    count: violations.length,
    summary,
  })

  return summary
}

const printViolationsToConsole = (violations) => {
  if (!violations.length) {
    // eslint-disable-next-line no-console
    console.info('[axe] No accessibility violations detected')
    return
  }

  // eslint-disable-next-line no-console
  console.groupCollapsed(`[axe] ${violations.length} accessibility violation${
    violations.length === 1 ? '' : 's'
  }`)
  summarizeViolations(violations).forEach((violation, violationIndex) => {
    // eslint-disable-next-line no-console
    console.groupCollapsed(`${violation.impact ?? 'minor'} – ${violation.id}`)
    // eslint-disable-next-line no-console
    console.table(
      violation.targets.map((target, index) => ({
        target,
        html: violations[violationIndex]?.nodes[index]?.html,
        description: violation.description,
      })),
    )
    // eslint-disable-next-line no-console
    console.groupEnd()
  })
  // eslint-disable-next-line no-console
  console.groupEnd()
}

const logViolations = (violations) => {
  const summary = logViolationsToNode(violations)

  if (!violations.length) {
    Cypress.log({
      name: 'axe',
      message: 'No accessibility violations detected',
    })
    printViolationsToConsole(violations)
    return
  }

  Cypress.log({
    name: 'axe',
    message: `${violations.length} accessibility violation${violations.length === 1 ? '' : 's'}`,
    consoleProps: () => summary,
  })

  violations.forEach(({ id, impact, description, nodes }) => {
    Cypress.log({
      name: 'axe',
      message: `${impact ?? 'minor'} – ${id}`,
      consoleProps: () => ({
        description,
        nodes: nodes.map(({ target, html, failureSummary }) => ({
          target,
          html,
          failureSummary,
        })),
      }),
    })
  })

  printViolationsToConsole(violations)
}

Cypress.Commands.add('checkA11yAndLog', (contextOverride, optionsOverride = {}, skipFailuresOverride) => {
  const defaults = getDefaultAxeConfig()
  const context = contextOverride ?? defaults.context
  const skipFailures =
    typeof skipFailuresOverride === 'boolean' ? skipFailuresOverride : defaults.skipFailures

  const options = mergeAxeOptions(defaults.options, optionsOverride)
  const axeOptions = Object.keys(options).length ? options : undefined

  cy.checkA11y(context, axeOptions, logViolations, skipFailures)
})

Cypress.Commands.add('runA11y', ({ context, options, skipFailures } = {}) => {
  cy.injectAxe()
  cy.checkA11yAndLog(context, options, skipFailures)
})
