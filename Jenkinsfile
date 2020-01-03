#!/groovy
// Load our custom groovy library
@Library('jenkins-pipeline-lib@master')_

node {
    def env
    def version
    stage('Checkout') {
        echo 'INFO: Getting the code...'
        try {
            sh 'mkdir cookbook'
            dir('cookbook') {
                checkout scm
            }
        } catch (error) {
            echo '\'Checkout\' Stage ran into errors'
            throw error
        }
    }
    stage('Setup Environment') {
        echo 'INFO: Setting up the build environment.'
        try {
            if (env.BRANCH_NAME == 'master') {
                env = 'production'
            } else if (env.BRANCH_NAME == 'qa') {
                env = 'qa'
            } else if (evn.BRANCH_NAME == 'staging') {
                env = 'staging'
            } else {
                env = 'development'
            }
            version = '0.1.0'
        } catch (error) {
            echo '\'Setup Envirnment\' Stage ran into errors'
            throw error
        }
    }
    dir('cookbook') {
        stage('Linting') {
            echo "INFO: Lint checking ${env} cookbook v${version}."
            try {
                sh 'chef exec foodcritic .'
                sh 'chef exec rubocop .'
            } catch (error) {
                echo '\'Linting\' Stage ran into errors'
                throw error
            }
        }
        stage('Build') {
            echo "INFO: Starting build stage for ${env} cookbook v${version}."
            try {
                sh 'kitchen converge'
            } catch (error) {
                echo '\'Build\' Stage ran into errors'
                throw error
            }
        }
        stage('Testing') {
            echo "INFO: Starting tests for ${env} cookbook v${version}."
            try {
                sh 'chef exec rspec -fd'
                sh 'kitchen verify'
            } catch (error) {
                echo '\'Testing\' Stage ran into errors'
                throw error
            }
        }
        if (env != 'development') {
            stage('Deploy') {
                echo "INFO: Deploying ${env} cookbook v${version} to Chef Server."
                try {
                    sh 'berks upload'
                } catch (error) {
                    echo '\'Deploy\' Stage ran into errors'
                    throw error
                }
            }
        }

    }
    stage('Cleanup') {
        echo "INFO: Build/test stages were successful for ${env} cookbook ${version}.  Cleaning up workspace."
        try {
            dir('cookbook') {
                sh 'kitchen destroy'
            }
            sh 'rm -Rf ./*'
        } catch (error) {
            echo '\'Cleanup\' Stage ran into errors'
            throw error
        }
    }        
}
